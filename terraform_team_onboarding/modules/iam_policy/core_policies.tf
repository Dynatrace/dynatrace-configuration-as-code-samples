resource "dynatrace_iam_policy" "admin" {
  name            = "Admin"
  description     = "managed Admin policy"
  account         = var.account_id
  statement_query = <<-EOT
    ${var.policy_definitions.admin}
  EOT
}

resource "dynatrace_iam_policy" "data_access" {
  name            = "Data Access"
  description     = <<-EOT
    View all data (except logs)
    View all confidential logs
  EOT
  account         = var.account_id
  statement_query = <<-EOT
    ${var.policy_definitions.data_access}
  EOT
}

resource "dynatrace_iam_policy" "functional" {
  name            = "Functional"
  description     = <<-EOT
    Allow access to view all config, and apps.
    No data access granted via this policy
  EOT
  account         = var.account_id
  statement_query = <<-EOT
    ${var.policy_definitions.functional}
  EOT
}

resource "dynatrace_iam_policy" "functional_viewer" {
  name            = "Functional Viewer Only"
  description     = <<-EOT
    Allow access to only view all apps.
    No data access granted via this policy
  EOT
  account         = var.account_id
  statement_query = <<-EOT
    ${var.policy_definitions.functional_viewer}
  EOT
}

resource "dynatrace_iam_policy" "additional_data" {
  name            = "Additional Data"
  description     = "Service specific data access - scoped via a boundary"
  account         = var.account_id
  statement_query = <<-EOT
    ${var.policy_definitions.additional_data}
  EOT
}

resource "dynatrace_iam_policy" "poweruser" {
  name            = "Poweruser"
  description     = "Service specific power user access - once scoped via a boundary"
  account         = var.account_id
  statement_query = <<-EOT
    ${var.policy_definitions.poweruser}
  EOT
}

resource "dynatrace_iam_policy" "unscoped_settings" {
  name            = "Unscoped Settings"
  description     = "Additional policies for powerusers to allow to configure all extensions, and global settings that are not scoped by boundary"
  account         = var.account_id
  statement_query = <<-EOT
    ${var.policy_definitions.unscoped_settings}
  EOT
}

resource "dynatrace_iam_policy" "sandbox" {
  name            = "Additional Sandbox"
  description     = "Additional policies to be applied to sandbox environment"
  account         = var.account_id
  statement_query = <<-EOT
    ${var.policy_definitions.sandbox}
  EOT
}
