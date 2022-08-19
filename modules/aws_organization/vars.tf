variable "feature_set" {
  description = "The feature set of the organization. One of 'ALL' or 'CONSOLIDATED_BILLING'. Default is 'ALL'."
  type        = string
  default     = "ALL"
}

variable "organizational_units" {
  description = "The tree of organizational units to construct. Defaults to an empty tree."
  type = list(object({
    name = string,
    children = list(object({
      name = string,
      children = list(object({
        name = string
      }))
    }))
  }))
  default = []
}

variable "accounts" {
  description = "The set of accounts to create. Defaults to an empty list."
  type = list(object({
    name                              = string,
    email                             = string,
    organizational_unit               = string,
    allow_iam_users_access_to_billing = bool,
  }))
  default = []
}