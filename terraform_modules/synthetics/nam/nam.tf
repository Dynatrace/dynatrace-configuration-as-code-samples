locals {
  input_data   = try(jsondecode(file(var.input)), var.input)
  locationJson = jsondecode(data.dynatrace_dql.locations.records)
  locations    = tomap({ for loc in local.locationJson : loc.location => loc.id })
}

// Network monitors can only run from private locations
data "dynatrace_dql" "locations" {
  query = <<EOT
fetch dt.entity.synthetic_location
| fieldsAdd locationType
| filter locationType != "PUBLIC"
| fields location = entity.name, id
EOT
}

resource "dynatrace_network_monitor" "monitor" {
  for_each = { for nam in local.input_data : nam["name"] => nam }

  name          = "${each.key} [${var.application_tag}]"
  description   = "${each.key} network monitor"
  type          = "MULTI_PROTOCOL"
  frequency_min = try(each.value.frequency, 5)
  locations     = [try(local.locations["${each.value.location}"], local.locations["${each.value.location} aws"], local.locations["${var.location}"])]
  outage_handling {
    global_consecutive_outage_count_threshold = 3
  }
  performance_thresholds {}

  steps {
    dynamic "step" {
      for_each = each.value.requiredSynthetics
      content {
        name         = "${each.key}_step_${step.value.port}"
        request_type = try(step.value.nam_type, var.nam_type)
        target_list  = step.value.ips
        constraints {
          constraint {
            type = "SUCCESS_RATE_PERCENT"
            properties = {
              "value"    = "99"
              "operator" = ">="
            }
          }
        }

        dynamic "request_configurations" {
          for_each = try(step.value.nam_type, var.nam_type) == "ICMP" ? ["ICMP_configurations"] : []
          content {
            request_configuration {
              constraints {
                constraint {
                  type = "ICMP_SUCCESS_RATE_PERCENT"
                  properties = {
                    "operator" = ">="
                    "value"    = "100"
                  }
                }
              }
            }
          }
        }

        properties = try(step.value.nam_type, var.nam_type) == "TCP" ? {
          "EXECUTION_TIMEOUT" = "PT1S"
          "TCP_PORT_RANGES"   = step.value.port
          } : {
          "ICMP_TIMEOUT_FOR_REPLY"    = "PT1S"
          "ICMP_TIME_TO_LIVE"         = "64"
          "ICMP_DO_NOT_FRAGMENT_DATA" = "true"
          "ICMP_IP_VERSION"           = "4"
          "EXECUTION_TIMEOUT"         = "PT1S"
          "ICMP_PACKET_SIZE"          = "32"
          "ICMP_NUMBER_OF_PACKETS"    = "1"
        }
      }
    }
  }
  tags {
    tag {
      context = "CONTEXTLESS"
      key   = "Application"
      value = var.application_tag
    }
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
