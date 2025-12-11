locals {
  hostGroups = jsondecode(data.dynatrace_dql.host_group_dql)
}

data "dynatrace_dql" "host_group_dql" {
  query = <<EOT
  fetch dt.entity.host_group
  | filter startsWith(entity.name, "a_team1")
EOT
}

resource "dynatrace_log_custom_source" "login-custom-resource" {
  for_each = {for hg in local.hostGroups: hg.id => hg}
  name    = "Custom log path monitoring"
  enabled = true
  scope   = "${each.id}"
  custom_log_source {
    type = "LOG_PATH_PATTERN"
    values_and_enrichment {
      custom_log_source_with_enrichment {
        path = "/tmp/custom-data.log"
      }
    }
  }
}
