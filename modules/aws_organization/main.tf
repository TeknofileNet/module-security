##############################################################
# This module implements an AWS organization
##############################################################

##############################################################
# AWS Provider Configs
##############################################################

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      ExampleDefaultTag = "ExampleDefaultValue"
    }
  }
}


locals {
  name   = "ex-${replace(basename(path.cwd), "_", "-")}"
  region = "us-west-1"

  tags = {
    Example    = local.name
    GithubRepo = "module-security"
    GithubOrg  = "TeknofileNet"
  }
}



resource "aws_organizations_organization" "organization" {
  feature_set = var.feature_set
}

locals {
  level_1_ou_arguments = [
    for ou in var.organizational_units : ou
  ]
  level_2_ou_arguments = flatten([
    for level_1_ou in var.organizational_units :
    [for level_2_ou in level_1_ou.children :
      {
        name : level_2_ou.name,
        parent : index(var.organizational_units, level_1_ou)
      }
    ]
  ])
  level_3_ou_arguments = flatten([
    for level_1_ou in var.organizational_units :
    [for level_2_ou in level_1_ou.children :
      [for level_3_ou in level_2_ou.children :
        {
          name : level_3_ou.name,
          parent : index(level_1_ou.children, level_2_ou)
        }
      ]
    ]
  ])
}

resource "aws_organizations_organizational_unit" "level_1_ous" {
  count     = length(local.level_1_ou_arguments)
  name      = local.level_1_ou_arguments[count.index].name
  parent_id = aws_organizations_organization.organization.roots[0].id
}

resource "aws_organizations_organizational_unit" "level_2_ous" {
  count     = length(local.level_2_ou_arguments)
  name      = local.level_2_ou_arguments[count.index].name
  parent_id = aws_organizations_organizational_unit.level_1_ous[local.level_2_ou_arguments[count.index].parent].id
}

resource "aws_organizations_organizational_unit" "level_3_ous" {
  count     = length(local.level_3_ou_arguments)
  name      = local.level_3_ou_arguments[count.index].name
  parent_id = aws_organizations_organizational_unit.level_2_ous[local.level_3_ou_arguments[count.index].parent].id
}

locals {
  level_1_ou_attributes = [
    for ou in local.level_1_ou_arguments :
    {
      id        = aws_organizations_organizational_unit.level_1_ous[index(local.level_1_ou_arguments, ou)].id,
      arn       = aws_organizations_organizational_unit.level_1_ous[index(local.level_1_ou_arguments, ou)].arn,
      parent_id = aws_organizations_organization.organization.roots[0].id,
      name      = ou.name,
    }
  ]
  level_2_ou_attributes = [
    for ou in local.level_2_ou_arguments :
    {
      id        = aws_organizations_organizational_unit.level_2_ous[index(local.level_2_ou_arguments, ou)].id,
      arn       = aws_organizations_organizational_unit.level_2_ous[index(local.level_2_ou_arguments, ou)].arn,
      parent_id = aws_organizations_organizational_unit.level_1_ous[ou.parent].id,
      name      = ou.name
    }
  ]
  level_3_ou_attributes = [
    for ou in local.level_3_ou_arguments :
    {
      id        = aws_organizations_organizational_unit.level_3_ous[index(local.level_3_ou_arguments, ou)].id,
      arn       = aws_organizations_organizational_unit.level_3_ous[index(local.level_3_ou_arguments, ou)].arn,
      parent_id = aws_organizations_organizational_unit.level_2_ous[ou.parent].id,
      name      = ou.name
    }
  ]
  all_ou_attributes = concat(
    local.level_1_ou_attributes,
    local.level_2_ou_attributes,
    local.level_3_ou_attributes
  )
}

resource "aws_organizations_account" "account" {
  count = length(var.accounts)

  name  = var.accounts[count.index].name
  email = var.accounts[count.index].email

  iam_user_access_to_billing = var.accounts[count.index].allow_iam_users_access_to_billing ? "ALLOW" : "DENY"

  parent_id = [for ou in local.all_ou_attributes : ou.id if ou.name == var.accounts[count.index].organizational_unit][0]
}

locals {
  all_account_attributes = [
    for account in aws_organizations_account.account[*] :
    {
      id        = account.id,
      arn       = account.arn,
      name      = account.name
      email     = account.email
      parent_id = account.parent_id,
      parent_ou = var.accounts[index(aws_organizations_account.account[*], account)].organizational_unit,
    }
  ]
}