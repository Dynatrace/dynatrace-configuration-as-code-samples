resource "dynatrace_iam_group" "admin" {
  name                       = "Admin"
  description                = <<-EOT
    Admin access to all environments
    Manage all configuration, users
    Only view access to data
  EOT
  federated_attribute_values = [var.entra_id_map["app-UNI-GBL-Dynatrace-Admins"]]

  lifecycle {
    ignore_changes = [permissions]
  }
}

resource "dynatrace_iam_policy_bindings_v2" "admin_user_bind" {
  group   = dynatrace_iam_group.admin.id
  account = var.account_id
  policy {
    id = var.policies.functional
  }
  policy {
    id = var.policies.data_access
  }
  policy {
    id = var.policies.admin
  }
}


resource "dynatrace_iam_permission" "admin_account_viewer_permission" {
  name    = "account-viewer"
  group   = dynatrace_iam_group.admin.id
  account = var.account_id
}

resource "dynatrace_iam_permission" "admin_account_user_management_permission" {
  name    = "account-user-management"
  group   = dynatrace_iam_group.admin.id
  account = var.account_id
}

resource "dynatrace_iam_permission" "admin_account_company_info_permission" {
  name    = "account-company-info"
  group   = dynatrace_iam_group.admin.id
  account = var.account_id
}

resource "dynatrace_iam_permission" "admin_tenant_manage_support_tickets_permission_sandbox" {
  name        = "tenant-manage-support-tickets"
  group       = dynatrace_iam_group.admin.id
  environment = var.environments.sandbox
}

resource "dynatrace_iam_permission" "admin_tenant_manage_support_tickets_permission_nonprod" {
  name        = "tenant-manage-support-tickets"
  group       = dynatrace_iam_group.admin.id
  environment = var.environments.nonproduction
}

resource "dynatrace_iam_permission" "admin_tenant_manage_support_tickets_permission_prod" {
  name        = "tenant-manage-support-tickets"
  group       = dynatrace_iam_group.admin.id
  environment = var.environments.production
}
