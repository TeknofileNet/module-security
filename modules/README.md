Original work forked from: https://github.com/infrablocks/terraform-aws-organization.

A Terraform module for managing an AWS Organization.

The organization deployment has no requirements.

The organization deployment consists of:

* An AWS organisation
* A hierarchy of organisational units
* A set of accounts placed in that hierarchy

## Usage

See in `examples`: (aws_organization_complete)[https://github.com/TeknofileNet/module-security/examples/aws_organization_complete]

Note: organizational_units can be nested up to 3 levels deep. Levels 1 & 2 must include a children property although it can be an empty array. Level 3 must not include a children property.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->