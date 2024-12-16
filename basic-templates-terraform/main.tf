provider "dynatrace" {
  alias        = "nonprod"
  dt_env_url   = var.DYNATRACE_ENV_URL
  dt_api_token = var.DYNATRACE_API_TOKEN
}

resource "dynatrace_management_zone_v2" "DaniloTest" {
  name = var.managementZoneName
  rules {
    rule {
      type    = "DIMENSION"
      enabled = true
      dimension_rule {
        applies_to = "METRIC"
        dimension_conditions {
          condition {
            condition_type = "METRIC_KEY"
            rule_matcher   = "BEGINS_WITH"
            value          = "log."
          }
        }
      }
    }
    rule {
      type    = "ME"
      enabled = true
      attribute_rule {
        entity_type           = "HOST"
        host_to_pgpropagation = false
        attribute_conditions {
          condition {
            key      = "HOST_OS_TYPE"
            operator = "EXISTS"
          }
        }
      }
    }
    rule {
      type    = "ME"
      enabled = true
      attribute_rule {
        entity_type           = "HOST"
        host_to_pgpropagation = true
        attribute_conditions {
          condition {
            key      = "HOST_TAGS"
            operator = "EQUALS"
            tag = "[CONTEXT]dt.owner:azure-vm"
          }
        }
      }
    }
  }
}

output "management_zone_id" {
  value = dynatrace_management_zone_v2.DaniloTest.id
}


resource "dynatrace_alerting" "Terraform_test" {
  name            = var.alertingProfileName
  management_zone = dynatrace_management_zone_v2.DaniloTest.id 
  rules {
    rule {
      delay_in_minutes = 0
      include_mode     = "NONE"
      severity_level   = "AVAILABILITY"
    }
    rule {
      delay_in_minutes = 0
      include_mode     = "NONE"
      severity_level   = "CUSTOM_ALERT"
    }
    rule {
      delay_in_minutes = 0
      include_mode     = "NONE"
      severity_level   = "ERRORS"
    }
    rule {
      delay_in_minutes = 0
      include_mode     = "NONE"
      severity_level   = "MONITORING_UNAVAILABLE"
    }
    rule {
      delay_in_minutes = 30
      include_mode     = "NONE"
      severity_level   = "PERFORMANCE"
    }
    rule {
      delay_in_minutes = 30
      include_mode     = "NONE"
      severity_level   = "RESOURCE_CONTENTION"
    }
  }
}

output "alerting_profile_id" {
  value = dynatrace_alerting.Terraform_test.id
}


resource "dynatrace_autotag_v2" "Terraform_test_tag" {
  name                          = var.autoTagName
  description                   = "Export value and test"
  # rules_maintained_externally = false
  rules {
    rule {
      type                = "ME"
      enabled             = true
      value_normalization = "Leave text as-is"
      attribute_rule {
        entity_type           = "HOST"
        host_to_pgpropagation = true
        conditions {
          condition {
            string_value = "azure"
            key       = "HOST_NAME"
            operator  = "CONTAINS"
          }
        }
      }
    }
  }
}


resource "dynatrace_web_application" "EasyTrade" {
  name                                 = var.webApplicationName
  type                                 = "AUTO_INJECTED"
  cost_control_user_session_percentage = 100
  load_action_key_performance_metric   = "VISUALLY_COMPLETE"
  real_user_monitoring_enabled         = true
  xhr_action_key_performance_metric    = "VISUALLY_COMPLETE"
  custom_action_apdex_settings {
    frustrating_fallback_threshold = 12000
    frustrating_threshold          = 12000
    tolerated_fallback_threshold   = 3000
    tolerated_threshold            = 3000
  }
  load_action_apdex_settings {
    frustrating_fallback_threshold = 12000
    frustrating_threshold          = 12000
    tolerated_fallback_threshold   = 3000
    tolerated_threshold            = 3000
  }
  monitoring_settings {
    cache_control_header_optimizations   = true
    # cookie_placement_domain            = ""
    # correlation_header_inclusion_regex = ""
    # custom_configuration_properties    = ""
    # exclude_xhr_regex                  = ""
    fetch_requests                       = true
    injection_mode                       = "JAVASCRIPT_TAG"
    # library_file_location              = ""
    # monitoring_data_path               = ""
    # secure_cookie_attribute            = false
    # server_request_path_id             = ""
    xml_http_request                     = true
    advanced_javascript_tag_settings {
      # instrument_unsupported_ajax_frameworks = false
      max_action_name_length                   = 100
      max_errors_to_capture                    = 10
      # special_characters_to_escape           = ""
      # sync_beacon_firefox                    = false
      # sync_beacon_internet_explorer          = false
      additional_event_handlers {
        # blur                          = false
        # change                        = false
        # click                         = false
        max_dom_nodes                   = 5000
        # mouseup                       = false
        # to_string_method              = false
        # use_mouse_up_event_for_clicks = false
      }
      global_event_capture_settings {
        # additional_event_captured_as_user_input = ""
        change                                    = true
        click                                     = true
        doubleclick                               = true
        keydown                                   = true
        keyup                                     = true
        mousedown                                 = true
        mouseup                                   = true
        scroll                                    = true
        touch_end                                 = true
        touch_start                               = true
      }
    }
    content_capture {
      javascript_errors                 = true
      visually_complete_and_speed_index = true
      resource_timing_settings {
        instrumentation_delay      = 50
        # non_w3c_resource_timings = false
        w3c_resource_timings       = true
      }
      timeout_settings {
        temporary_action_limit         = 0
        temporary_action_total_timeout = 100
        # timed_action_support         = false
      }
      visually_complete_settings {
        # exclude_url_regex      = ""
        # ignored_mutations_list = ""
        inactivity_timeout       = 1000
        mutation_timeout         = 50
        threshold                = 50
      }
    }
    javascript_framework_support {
      # active_x_object = false
      # angular         = false
      # dojo            = false
      # extjs           = false
      # icefaces        = false
      # jquery          = false
      # moo_tools       = false
      # prototype       = false
    }
  }
  session_replay_config {
    enabled                       = var.sessionReplayEnabled
    cost_control_percentage       = var.sessionReplayPercentage
    enable_css_resource_capturing = true
  }
  user_action_naming_settings {
    ignore_case                      = true
    query_parameter_cleanups         = [ "cfid", "phpsessid", "__sid", "cftoken", "sid" ]
    split_user_actions_by_domain     = true
    # use_first_detected_load_action = false
  }
  waterfall_settings {
    resource_browser_caching_threshold            = 50
    resources_threshold                           = 100000
    slow_cnd_resources_threshold                  = 200000
    slow_first_party_resources_threshold          = 200000
    slow_third_party_resources_threshold          = 200000
    speed_index_visually_complete_ratio_threshold = 50
    uncompressed_resources_threshold              = 860
  }
  xhr_action_apdex_settings {
    frustrating_fallback_threshold = 12000
    frustrating_threshold          = 12000
    tolerated_fallback_threshold   = 3000
    tolerated_threshold            = 3000
  }
}

output "web_application_id" {
  value = dynatrace_web_application.EasyTrade.id
}


resource "dynatrace_application_detection_rule" "EasyTrade_App_Detection" {
  application_identifier = dynatrace_web_application.EasyTrade.id
  filter_config {
    application_match_target = "DOMAIN"
    application_match_type   = "MATCHES"
    pattern                  = "easytrade-test"
  }
}


resource "dynatrace_ownership_config" "Ownership" {
  ownership_identifiers {
    ownership_identifier {
      enabled = true
      key     = "dt.owner"
    }
    ownership_identifier {
      enabled = true
      key     = "owner"
    }
  }
}


resource "dynatrace_ownership_teams" "Platform_Enginners" {
  name       = var.ownershipConfigName
  identifier = var.ownershipConfigName
  contact_details {
    contact_detail {
      email            = var.ownershipContact
      integration_type = "EMAIL"
    }
  }
  responsibilities {
    development      = true
    infrastructure   = true
    line_of_business = false
    operations       = true
    security         = false
  }
}


resource "dynatrace_email_notification" "DaniloEmail" {
  name                   = var.emailNotificationName
  # active               = false
  body                   = "{ProblemDetailsText}"
  notify_closed_problems = true
  profile                = dynatrace_alerting.Terraform_test.id
  subject                = "{State} Problem {ProblemID}: {ImpactedEntity}"
  to                     = [ var.ownershipContact ]
}


resource "dynatrace_http_monitor" "Terraform_test_HTTP" {
  name      = var.httpMonitorName
  enabled   = true
  frequency = var.httpMonitorFrequency
  locations = [var.httpLocationId ]
  anomaly_detection {
    loading_time_thresholds {
      # enabled = false
    }
    outage_handling {
      global_outage    = true
      # local_outage   = false
      # retry_on_error = false
      global_outage_policy {
        consecutive_runs = 1
      }
    }
  }
  script {
    request {
      description = var.httpMonitorName
      method      = "GET"
      url         = var.httpMonitorUrl
      configuration {
        accept_any_certificate = true
        follow_redirects       = true
      }
      validation {
        rule {
          type            = "httpStatusesList"
          # pass_if_found = false
          value           = ">=400"
        }
      }
    }
  }
}


resource "dynatrace_slo_v2" "Service_Level_Objective_Terraform_Test" {
  name              = var.sloConfigName
  enabled           = true
  evaluation_type   = "AGGREGATE"
  evaluation_window = "-1w"
  filter            =<<-EOT
    type("SERVICE"), tag("environment:${var.releaseStage}")
    
  EOT
  metric_expression =<<-EOT
    ((builtin:service.response.time:avg:partition("latency",value("good",lt(1000))):splitBy():count:default(1))/(builtin:service.response.time:avg:splitBy():count)*(100))
  EOT
  metric_name       = "${var.sloMetricName}_${var.releaseStage}_response_time"
  target_success    = 98
  target_warning    = 99
  error_budget_burn_rate {
    burn_rate_visualization_enabled = true
    fast_burn_threshold             = 10
  }
}
