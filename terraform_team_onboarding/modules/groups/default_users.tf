resource "dynatrace_iam_group" "default_viewer_contactor_group" {
  name                       = "Default Viewer - Contractor"
  description                = "To be removed when it can be linked with Default Viewer"
  federated_attribute_values = [var.entra_id_map["App-Prod-Dynatrace-External"]]
}

resource "dynatrace_iam_group" "default_viewer_group" {
  name                       = "Default user"
  description                =<<-EOT
    Basic user access granted to all.
    Access to view all data (except logs)
    Access to view all configuration
    Only view logs marked confidential
  EOT
  federated_attribute_values = [var.entra_id_map["App-Prod-All-Users"]]
}

resource "dynatrace_iam_policy_bindings_v2" "default_viewer_group_bind_sandbox" {
  group       = dynatrace_iam_group.default_viewer_group.id
  environment = var.environments.sandbox
  policy {
    id = var.policies.sandbox
  }
  policy {
    id = var.policies.data_access
  }
  policy {
    id = var.policies.functional
  }
}

resource "dynatrace_iam_policy_bindings_v2" "default_viewer_group_bind_nonprod" {
  group       = dynatrace_iam_group.default_viewer_group.id
  environment = var.environments.nonproduction
  policy {
    id = var.policies.data_access
  }
  policy {
    id = var.policies.functional
  }
}

resource "dynatrace_iam_policy_bindings_v2" "default_viewer_group_bind_prod" {
  group       = dynatrace_iam_group.default_viewer_group.id
  environment = var.environments.production
  policy {
    id = var.policies.data_access
  }
  policy {
    id = var.policies.functional
  }
}

# ------ Bindings for contractor should be same as default
resource "dynatrace_iam_policy_bindings_v2" "default_viewer_contactor_group_bind_sandbox" {
  group       = dynatrace_iam_group.default_viewer_contactor_group.id
  environment = var.environments.sandbox
  policy {
    id = var.policies.sandbox
  }
  policy {
    id = var.policies.data_access
  }
  policy {
    id = var.policies.functional
  }
}

resource "dynatrace_iam_policy_bindings_v2" "default_viewer_contactor_group_bind_nonprod" {
  group       = dynatrace_iam_group.default_viewer_contactor_group.id
  environment = var.environments.nonproduction
  policy {
    id = var.policies.data_access
  }
  policy {
    id = var.policies.functional
  }
}

resource "dynatrace_iam_policy_bindings_v2" "default_viewer_contactor_group_bind_prod" {
  group       = dynatrace_iam_group.default_viewer_contactor_group.id
  environment = var.environments.production
  policy {
    id = var.policies.data_access
  }
  policy {
    id = var.policies.functional
  }
}