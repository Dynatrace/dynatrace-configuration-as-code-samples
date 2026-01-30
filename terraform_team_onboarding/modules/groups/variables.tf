variable "groups" {
  type = any
  description = "Groups to create"
}
variable "environments" {
  type = any
  description = "Environment names as name:id pairs"
}
variable "policies" {
  type = any
  description = "Policies to be used as name:id pairs"
}
variable "entra_id_map" {
  type = any
  description = "EntraId groups to be used as name:id pairs"
}
variable "account_id" {
  default = "<ACCOUNT_ID>"
  description = "Account ID of target account"
}