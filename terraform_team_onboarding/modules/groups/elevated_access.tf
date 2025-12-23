resource "dynatrace_iam_group" "view_all" {
  name        = "temporary view all logs"
  description = "Elevated access to view all logs in the environment"
}

resource "dynatrace_iam_policy_bindings_v2" "view_all_bind_prod" {
  group       = dynatrace_iam_group.view_all.id
  environment = var.environments.production
  policy {
    id = var.policies.additional_data
  }
}

resource "dynatrace_iam_policy_bindings_v2" "view_all_bind_nonprod" {
  group       = dynatrace_iam_group.view_all.id
  environment = var.environments.nonproduction
  policy {
    id = var.policies.additional_data
  }
}