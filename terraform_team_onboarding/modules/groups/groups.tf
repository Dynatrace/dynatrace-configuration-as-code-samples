resource "dynatrace_iam_group" "poweruser_group" {
  for_each                   = var.groups
  name                       = "${each.value.team_name}: ${each.value.security_context} - power user"
  description                = "Poweruser Group for ${each.value.security_context}"
  federated_attribute_values = [var.entra_id_map["${each.value.poweruser_group}"]]
}

resource "dynatrace_iam_group" "logs_group" {
  for_each                   = var.groups
  name                       = "${each.value.team_name}: ${each.value.security_context} - data viewer"
  description                = "Additional Reader Group for ${each.value.security_context}"
  federated_attribute_values = [var.entra_id_map["${each.value.data_group}"]]
}

resource "dynatrace_iam_policy_bindings_v2" "poweruser_group_bind" {
  for_each    = var.groups
  group       = dynatrace_iam_group.poweruser_group[each.key].id
  environment = var.environments.production
  policy {
    id         = var.policies.poweruser
    boundaries = [dynatrace_iam_policy_boundary.boundary[each.key].id]
  }
  policy {
    id = var.policies.unscoped_settings
  }
}

resource "dynatrace_iam_policy_bindings_v2" "logs_group_bind" {
  for_each    = var.groups
  group       = dynatrace_iam_group.logs_group[each.key].id
  environment = var.environments.production
  policy {
    id         = var.policies.additional_data
    boundaries = [dynatrace_iam_policy_boundary.boundary[each.key].id]
  }
}

resource "dynatrace_iam_policy_bindings_v2" "poweruser_group_bind_nonprod" {
  for_each    = var.groups
  group       = dynatrace_iam_group.poweruser_group[each.key].id
  environment = var.environments.nonproduction
  policy {
    id         = var.policies.poweruser
    boundaries = [dynatrace_iam_policy_boundary.boundary[each.key].id]
  }
  policy {
    id = var.policies.unscoped_settings
  }
}

resource "dynatrace_iam_policy_bindings_v2" "logs_group_bind_nonprod" {
  for_each    = var.groups
  group       = dynatrace_iam_group.logs_group[each.key].id
  environment = var.environments.nonproduction
  policy {
    id         = var.policies.additional_data
    boundaries = [dynatrace_iam_policy_boundary.boundary[each.key].id]
  }
}

resource "dynatrace_iam_policy_boundary" "boundary" {
  for_each = var.groups
  name     = "${each.value.team_name}: ${each.value.security_context}"
  query    = "storage:dt.security_context startsWith \"${each.value.security_context}\"; storage:bucket-name startsWith \"${each.value.security_context}\"; storage:bucket-name startsWith \"${each.value.app_name}\"; storage:bucket-name startsWith \"default\"; environment:management-zone startsWith \"${each.value.app_name}\"; storage:file-path startsWith \"/lookups/${each.value.security_context}\";storage:file-path startsWith \"/lookups/confidential_${each.value.app_name}\";"
}