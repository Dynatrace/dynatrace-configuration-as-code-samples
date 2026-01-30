variable "azuread_dynatrace_client_secret" {
  type = string
  sensitive = true
  description = "Used to authenticate with Azure to get EntraID group IDs"
}
