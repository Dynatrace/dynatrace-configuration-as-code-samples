resource "dynatrace_iam_group" "viewer_only_group" {
  name                       = "TV Dashboards - viewer only group"
  description                = "Viewer only group for TV Dashboard accounts"
  federated_attribute_values = [var.entra_id_map["App-Prod-Dynatrace-TVDashboards"]]
}

resource "dynatrace_iam_policy_bindings_v2" "viewer_only_group_bind" {
  group       = dynatrace_iam_group.viewer_only_group.id
  environment = var.environments.production
  policy {
    id = var.policies.data_access
  }
  policy {
    id = var.policies.functional_viewer
  }
}

resource "dynatrace_iam_policy_bindings_v2" "viewer_only_group_bind_nonprod" {
  group       = dynatrace_iam_group.viewer_only_group.id
  environment = var.environments.nonproduction
  policy {
    id = var.policies.data_access
  }
  policy {
    id = var.policies.functional_viewer
  }
}