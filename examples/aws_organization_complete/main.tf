##############################################################
# This module implements an AWS organization
##############################################################

##############################################################
# How to use this module
#
# See ../../examples/aws_organization/ for a complete example
##############################################################

module "organisation" {
  source = "../../modules/aws_organization"

  feature_set = "ALL"

  organizational_units = [
    {
      name = "Root",
      children = [
        {
          name = "Parent",
          children = [
            {
              name = "Dev",
            },
            {
              name = "Test",
            },
            {
              name = "Prod"
            }
          ]
        }
      ]
    }
  ]

  accounts = [
    {
      name                              = "Development Account"
      email                             = "aws-dev-account@example.com"
      organizational_unit               = "Dev"
      allow_iam_users_access_to_billing = true
    },
    {
      name                              = "Staging"
      email                             = "aws-stage-account@example.com"
      organizational_unit               = "Test"
      allow_iam_users_access_to_billing = true
    },
    {
      name                              = "Production"
      email                             = "aws-prod-account@example.com"
      organizational_unit               = "Prod"
      allow_iam_users_access_to_billing = true
    },
    {
      name                              = "Shared Services"
      email                             = "shared-services@example.com"
      organizational_unit               = "Prod"
      allow_iam_users_access_to_billing = true
    }
  ]
}