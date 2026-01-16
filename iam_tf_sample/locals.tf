variable "config_file" {
    default = "./config/config.yaml"
}

locals {
  config = yamldecode(file(var.config_file))

  environments = lookup(local.config, "environments", {})
  openpipelines = lookup(local.config, "openpipelines", [])
  openpipeline_events = [
    for p in coalesce(local.openpipelines, []) : p #for p in local.openpipelines : p
    if lower(lookup(p, "pipeline_type", "")) == "events"
  ]

  openpipeline_logs = [
    for p in coalesce(local.openpipelines, []) : p #for p in local.openpipelines : p
    if lower(lookup(p, "pipeline_type", "")) == "logs"
  ]
  
  # Map groups, policies, boundaries by name for easy lookup. Do some basic integrity checks by filtering out entries that would fail during resource creation.
  groups_by_name            = { for g in local.config.teams      : g.name => g if g.name != null }
  policies_by_name_all      = { for p in local.config.policies    : p.name => p if p.name != null && (upper(p.type) != "EXISTING" && lookup(p,"statement_query", "FALSE")!="FALSE" || (upper(p.type) == "EXISTING")) }
  policies_by_name_existing  = {for p in local.policies_by_name_all: p.name => p if upper(lookup(p, "type", "CUSTOM")) == "EXISTING"}
  policies_by_name_custom   = {for p in local.policies_by_name_all: p.name => p if upper(lookup(p, "type", "CUSTOM")) != "EXISTING"}
  boundaries_by_name        = { for b in local.config.boundaries  : b.name => b if b.query != null && b.name != null}

 team_permissions = {
    for grant in lookup(local.config, "grants", []) :
    tostring(grant.id) => [
      for permission in lookup(grant, "permissions", []) : merge(
        permission,
        lower(permission.type) == "account"
          ? { scope = lookup(permission, "scope", var.DT_ACCOUNT_ID) }
          : {},
        lower(permission.type) == "tenant"
          ? { scope = lookup(local.environments, lookup(permission, "scope", ""), lookup(permission, "scope", "")) }
          : {},
        lower(permission.type) == "management-zone"
          ? { scope = lookup(permission, "scope", null) }
          : {}
      )
    ]
    if length(lookup(grant, "permissions", [])) > 0
  }

  bindings_with_account_id = [
    for binding in local.config.grants : {
      id      = binding.id
      teamname = binding.teamname
      policies = [
        for policy in binding.policies : merge(
          policy,
          upper(policy.levelType) == "ACCOUNT" && !contains(keys(policy), "levelId")
            ? { levelId = var.DT_ACCOUNT_ID }
            : {}
        )
      ]
      permissions = lookup(binding, "permissions", [])
    }
  ]

  bindings_with_details_split = flatten([
    for binding in local.bindings_with_account_id : [
      for scope in distinct(flatten([
        for policy_ref in binding.policies : [
          upper(policy_ref.levelType) == "ENVIRONMENT"
            ? { levelType = "ENVIRONMENT", levelId = lookup(local.environments, policy_ref.levelId, policy_ref.levelId) }
            : { levelType = "ACCOUNT", levelId = lookup(policy_ref, "levelId", null) != null ? policy_ref.levelId : var.DT_ACCOUNT_ID }
        ]
      ])) : {
        id       = binding.id
        groupname = binding.teamname
        levelType = scope.levelType
        levelId   = scope.levelId
        policies = [
          for policy_ref in binding.policies : (
            contains(keys(local.policies_by_name_all), policy_ref.name) &&
            (
              (scope.levelType == "ENVIRONMENT" && upper(policy_ref.levelType) == "ENVIRONMENT" && lookup(local.environments, policy_ref.levelId, policy_ref.levelId) == scope.levelId) ||
              (scope.levelType == "ACCOUNT" && upper(policy_ref.levelType) == "ACCOUNT" && (lookup(policy_ref, "levelId", null) == scope.levelId || (lookup(policy_ref, "levelId", null) == null && scope.levelId == var.DT_ACCOUNT_ID)))
            )
            ? merge(
                {
                  levelType = policy_ref.levelType
                  levelId   = scope.levelId
                  boundaries = (
                    lookup(policy_ref, "boundaries", null) != null ?
                    [
                      for b in policy_ref.boundaries : local.boundaries_by_name[b]
                      if contains(keys(local.boundaries_by_name), b)
                    ] :
                    []
                  )
                  parameters = lookup(policy_ref, "parameters", [])
                },
                local.policies_by_name_all[policy_ref.name]
              )
            : null
          )
          if policy_ref != null
        ]
        permissions = binding.permissions
      } if contains(keys(local.groups_by_name), binding.teamname)
    ]
  ])


}