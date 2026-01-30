locals {
  input_data   = try(jsondecode(file(var.input)), var.input)
  locationJson = jsondecode(data.dynatrace_dql.locations.records)
  locations    = tomap({ for loc in local.locationJson : loc.location => loc.id })
}

// Adjust to control the locations a user can choose from.
data "dynatrace_dql" "locations" {
  query = <<EOT
fetch dt.entity.synthetic_location
| fieldsAdd locationType
//| filter locationType != "PUBLIC"
| fields location = entity.name, id
| dedup location
EOT
}

resource "dynatrace_http_monitor" "http_monitor" {
  for_each  = { for http in local.input_data : http["name"] => http }
  name      = "${each.key} [${var.application_tag}]"
  frequency = try(each.value.frequency, 5)
  locations = [try(local.locations["${each.value.location}"], local.locations["${var.location}"])]
  enabled   = true
  anomaly_detection {
    loading_time_thresholds {
      # enabled = false
    }
    outage_handling {
      global_outage = true
      local_outage  = true
      # retry_on_error = false
      global_outage_policy {
        consecutive_runs = 1
      }
      local_outage_policy {
        affected_locations = 1
        consecutive_runs   = 2
      }
    }
  }
  script {
    dynamic "request" {
      for_each = each.value.requiredSynthetics
      content {
        description = request.value.url
        method      = "GET"
        url         = request.value.url
        configuration {
          # accept_any_certificate = false
          follow_redirects = true
        }
        validation {
          dynamic "rule" {
            for_each = try(request.value.httpStatusesList, true) != false ? ["HTTP status validation"] : []
            content {
              type = "httpStatusesList"
              # pass_if_found = false
              value = try(request.value.httpStatusesList, ">=400")
            }
          }
          dynamic "rule" {
            for_each = try(request.value.certificateVerification, false) != false ? ["Certificate validation"] : []
            content {
              type = "certificateExpiryDateConstraint"
              # pass_if_found = false
              value = request.value.certificateVerification
            }
          }
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
