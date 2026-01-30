resource "dynatrace_iam_group" "automation_users_group" {
  name                       = "Automation Users group"
  description                = "Group to allows users automation permissions"
  federated_attribute_values = [var.entra_id_map["App-Prod-Dynatrace-AutomationUsers"]]
}

resource "dynatrace_iam_policy_bindings_v2" "automation_users_bind" {
  group       = dynatrace_iam_group.automation_users_group.id
  environment = var.environments.production
  policy {
    id = var.policies.additional_automation
  }
}

resource "dynatrace_iam_policy_bindings_v2" "automation_users_bind_nonprod" {
  group       = dynatrace_iam_group.automation_users_group.id
  environment = var.environments.nonproduction
  policy {
    id = var.policies.additional_automation
  }
}
