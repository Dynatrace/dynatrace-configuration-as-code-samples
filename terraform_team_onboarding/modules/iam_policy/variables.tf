variable "account_id" {
  default = "<ACCOUNT_ID>"
  description = "Account ID of target account"
}

variable "policy_definitions" {
  type = any
  description = "Statements for policy creation as name:statement pairs"
}