locals {
  input_json = jsondecode(file("${path.module}/services-input.json"))

  flat_groups = flatten([
    for team in local.input_json : [
      for app in team.apps : {
        name             = "${team.team_name}: ${app.security_context}"
        team_name        = team.team_name
        data_group        = team.data_group
        poweruser_group  = team.poweruser_group
        security_context = app.security_context
        app_name         = app.app_name
      }
    ]
  ])

  groups = { for group in local.flat_groups : "${group.team_name}: ${group.security_context}" => group }

  policy_definitions = {
    "admin" : file("${path.module}/policy_definitions/admin.pol"),
    "data_access" : file("${path.module}/policy_definitions/data_access.pol"),
    "functional" : file("${path.module}/policy_definitions/functional.pol"),
    "functional_viewer" : file("${path.module}/policy_definitions/functional_viewer.pol"),
    "additional_data" : file("${path.module}/policy_definitions/additional_data.pol"),
    "poweruser" : file("${path.module}/policy_definitions/poweruser.pol"),
    "unscoped_settings" : file("${path.module}/policy_definitions/unscoped_settings.pol"),
    "sandbox" : file("${path.module}/policy_definitions/sandbox.pol"),
    "additional_automation" : file("${path.module}/policy_definitions/additional_automation.pol"),
    "additional_automation_tfe" : file("${path.module}/policy_definitions/additional_automation_tfe.pol"),
  }

  all_policies = {
    admin                     = module.iam_policy.admin_id
    data_access               = module.iam_policy.data_access_id
    functional                = module.iam_policy.functional_id
    functional_viewer         = module.iam_policy.functional_viewer_id
    additional_data           = module.iam_policy.additional_data_id
    poweruser                 = module.iam_policy.poweruser_id
    unscoped_settings         = module.iam_policy.unscoped_settings_id
    sandbox                   = module.iam_policy.sandbox_id
    additional_automation     = module.iam_policy.additional_automation_policy_id
    additional_automation_tfe = module.iam_policy.additional_automation_tfe_policy_id
  }


  environments = yamldecode(file("${path.module}/environments.yaml"))
  
  additional_groups = yamldecode(file("additional_groups.yaml"))
  svc_input_groups = distinct(flatten([
    for team in local.input_json : [
      team.poweruser_group, team.data_group
  ]]))
  input_groups = distinct(concat(local.additional_groups, local.svc_input_groups))

  entra_id_map = { for group in data.azuread_group.each_group : group.display_name => group.object_id }
}

data "azuread_group" "each_group" {
  for_each     = toset(local.input_groups)
  display_name = each.key
}

module "iam_policy" {
  source             = "./modules/iam_policy"
  policy_definitions = local.policy_definitions
}

module "groups" {
  source       = "./modules/groups"
  groups       = local.groups
  environments = local.environments
  policies     = local.all_policies
  entra_id_map = local.entra_id_map
}
