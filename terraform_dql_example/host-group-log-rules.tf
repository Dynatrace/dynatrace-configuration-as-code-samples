locals {
  hostGroups = jsondecode(data.dynatrace_dql.host_group_dql.records)
}

# Query for host group id’s matching our team. Update query as needed
data "dynatrace_dql" "host_group_dql" {
  query = <<EOT
  fetch dt.entity.host_group
  | filter startsWith(entity.name, "a_team1")
EOT
}

# Update log rules 
resource "dynatrace_log_custom_source" "custom_data_log" {
  for_each = { for hg in local.hostGroups : hg.id => hg }
  name     = "Custom log path monitoring"
  enabled  = true
  scope    = each.value.id
  custom_log_source {
    type = "LOG_PATH_PATTERN"
    values_and_enrichment {
      custom_log_source_with_enrichment {
        path = "/tmp/custom-data.log"
      }
    }
  }
}