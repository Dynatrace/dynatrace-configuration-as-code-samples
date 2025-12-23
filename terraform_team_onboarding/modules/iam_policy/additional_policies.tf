resource "dynatrace_iam_policy" "additional_automation" {
  name        = "Additional Automation"
  description = <<-EOT
    Allow additional automation permissions for users
  EOT
  account     = var.account_id
  # environment   = ""
  statement_query = <<-EOT
    ${var.policy_definitions.additional_automation}
  EOT
}

resource "dynatrace_iam_policy" "additional_automation_tfe" {
  name        = "Additional Automation TFE"
  description = <<-EOT
    Allow additional automation permissions for TFE service accounts
  EOT
  account     = var.account_id
  # environment   = ""
  statement_query = <<-EOT
    ${var.policy_definitions.additional_automation_tfe}
  EOT
}
