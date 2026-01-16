#region "team resources"
resource "dynatrace_platform_bucket" "teambuckets" {
  # Will not create any resources if buckets is missing or empty in config.yaml
  for_each = { for b in (can(local.config.buckets) && local.config.buckets != null ? local.config.buckets : []) : b.name => b }
  name         = each.value.name
  display_name = lookup(each.value, "display_name", format("%s/%s", "Bucket: ", each.value.name))
  retention    = lookup(each.value, "retention", 10)
  table        = lookup(each.value, "table", "logs")
}
#endregion "team resources"

#region "groups"
resource "dynatrace_iam_group" "new_groups" {
  for_each = { for group in local.groups_by_name : group.name => group }
  name     = each.value.name
  description = lookup(each.value, "description", null)
  federated_attribute_values =  lookup(each.value, "federated_attribute_values", null)

  dynamic "permissions" {
    for_each = length(lookup(local.team_permissions, each.value.name, [])) > 0 ? [1] : []
    content {
      dynamic "permission" {
        for_each = lookup(local.team_permissions, each.value.name, [])
        content {
          name  = permission.value.name
          type  = permission.value.type
          scope = permission.value.scope
        }
      }
    }
  }

}
#endregion "groups"

#region "policies"
# Refer to existing policies
data "dynatrace_iam_policy" "existing_policies" {
  for_each = {
    for p in local.policies_by_name_existing : p.name => p
  }
  name = each.value.name
}

# Create custom policies
resource "dynatrace_iam_policy" "custom" {
  for_each = { for p in local.policies_by_name_custom : p.name => p }
  name            = each.value.name
  description     = lookup(each.value, "description", null)
  account         = var.DT_ACCOUNT_ID
  statement_query = startswith(each.value.statement_query, var.FILE_PREFIX) ? file(substr(each.value.statement_query, length(var.FILE_PREFIX), -1)) : each.value.statement_query

}
#endregion "policies"


#region "boundaries"
resource "dynatrace_iam_policy_boundary" "bound" {
  for_each = { for b in local.boundaries_by_name : b.name => b}
  name  = each.value.name
  query = startswith(each.value.query, var.FILE_PREFIX) ? file(substr(each.value.query, length(var.FILE_PREFIX), -1)) : each.value.query
}
#endregion "boundaries"



#region "bindings"
resource "dynatrace_iam_policy_bindings_v2" "binding" {
  for_each = {
    for b in local.bindings_with_details_split :
    "${b.groupname}-${b.levelType}-${b.levelId}" => b
    if length(b.policies) > 0
  }

  group = dynatrace_iam_group.new_groups[each.value.groupname].id

  environment = each.value.levelType == "ENVIRONMENT" ? each.value.levelId : null
  account     = each.value.levelType == "ACCOUNT"     ? each.value.levelId : null

  dynamic "policy" {
    for_each = each.value.policies
    content {
        
      id = upper(policy.value.type) == "EXISTING" ? data.dynatrace_iam_policy.existing_policies[policy.value.name].uuid : dynatrace_iam_policy.custom[policy.value.name].uuid
      boundaries = [
        for each in policy.value.boundaries : dynatrace_iam_policy_boundary.bound[each.name].id
        if contains(keys(dynatrace_iam_policy_boundary.bound), each.name)
      ]
      parameters = (
        contains(keys(policy.value), "parameters") && policy.value.parameters != null
        ? { for p in policy.value.parameters : p.name => p.value }
        : {}
      )
    }
  }

  depends_on = [
    dynatrace_iam_group.new_groups,
    dynatrace_iam_policy.custom,
    dynatrace_iam_policy_boundary.bound,
    data.dynatrace_iam_policy.existing_policies
  ]
}
#endregion "bindings"

#region "open pipelines"
resource "dynatrace_openpipeline_events" "eventsonly" {
  # Will not create any resources if openpipelines is missing or empty in config.yaml
  for_each = length(local.openpipeline_events) > 0 ? { for idx, p in local.openpipeline_events : tostring(idx) => p } : {}

  dynamic "endpoints" {
    for_each = lookup(each.value, "endpoints", [])
    content {
      dynamic "endpoint" {
        for_each = [endpoints.value]
        content {
          enabled        = lookup(endpoint.value, "enabled", true)
          default_bucket = lookup(endpoint.value, "default_bucket", null)
          display_name   = lookup(endpoint.value, "display_name", null)
          segment        = lookup(endpoint.value, "segment", null)
          dynamic "routing" {
            for_each = [lookup(endpoint.value, "routing", {})]
            content {
              type        = routing.value.type
              pipeline_id = lookup(routing.value, "pipeline_id", null)
            }
          }
        }
      }
    }
  }

  pipelines {
      dynamic "pipeline" {
        for_each = lookup(each.value, "pipelines", [])
        content {
          enabled      = lookup(pipeline.value, "enabled", true)
          display_name = lookup(pipeline.value, "display_name", null)
          id           = pipeline.value.id

          dynamic "processing" {
            for_each = lookup(pipeline.value, "processing", null) != null ? [pipeline.value.processing] : []
            content {
              dynamic "processor" {
                for_each = lookup(processing.value, "processors", [])
                content {
                  # Example for fields_add_processor
                  dynamic "fields_add_processor" {
                    for_each = processor.value.type == "fields_add_processor" ? [processor.value] : []
                    content {
                      description = lookup(fields_add_processor.value, "description", null)
                      enabled     = lookup(fields_add_processor.value, "enabled", true)
                      id          = fields_add_processor.value.id
                      matcher     = fields_add_processor.value.matcher
                      dynamic "field" {
                        for_each = lookup(fields_add_processor.value, "fields", [])
                        content {
                          name  = field.value.name
                          value = field.value.value
                        }
                      }
                    }
                  }
                  # Add dynamic blocks for other processor types here (fields_rename_processor, dql_processor, etc.)
                }
              }
            }
          }



          # Data Extraction
          dynamic "data_extraction" {
            for_each = lookup(pipeline.value, "data_extraction", null) != null ? [pipeline.value.data_extraction] : []
            content {
              dynamic "processor" {
                for_each = lookup(data_extraction.value, "processors", [])
                content {
                  dynamic "davis_event_extraction_processor" {
                    for_each = processor.value.type == "davis_event_extraction_processor" ? [processor.value] : []
                    content {
                      description = lookup(davis_event_extraction_processor.value, "description", null)
                      enabled     = lookup(davis_event_extraction_processor.value, "enabled", true)
                      id          = davis_event_extraction_processor.value.id
                      matcher     = davis_event_extraction_processor.value.matcher
                      dynamic "properties" {
                        for_each = lookup(davis_event_extraction_processor.value, "properties", [])
                        content {
                          key   = properties.value.key
                          value = properties.value.value
                        }
                      }
                    }
                  }
                  # Add other data_extraction processor types as needed
                }
              }
            }
          }

          # Metric Extraction
          dynamic "metric_extraction" {
            for_each = lookup(pipeline.value, "metric_extraction", null) != null ? [pipeline.value.metric_extraction] : []
            content {
              dynamic "processor" {
                for_each = lookup(metric_extraction.value, "processors", [])
                content {
                  dynamic "value_metric_extraction_processor" {
                    for_each = processor.value.type == "value_metric_extraction_processor" ? [processor.value] : []
                    content {
                      description = lookup(value_metric_extraction_processor.value, "description", null)
                      enabled     = lookup(value_metric_extraction_processor.value, "enabled", true)
                      dimensions  = lookup(value_metric_extraction_processor.value, "dimensions", null)
                      field       = lookup(value_metric_extraction_processor.value, "field", null)
                      id          = value_metric_extraction_processor.value.id
                      matcher     = value_metric_extraction_processor.value.matcher
                      metric_key  = value_metric_extraction_processor.value.metric_key
                    }
                  }
                  dynamic "counter_metric_extraction_processor" {
                    for_each = processor.value.type == "counter_metric_extraction_processor" ? [processor.value] : []
                    content {
                      description = lookup(counter_metric_extraction_processor.value, "description", null)
                      enabled     = lookup(counter_metric_extraction_processor.value, "enabled", true)
                      id          = counter_metric_extraction_processor.value.id
                      matcher     = counter_metric_extraction_processor.value.matcher
                      metric_key  = counter_metric_extraction_processor.value.metric_key
                    }
                  }
                  # Add other metric_extraction processor types as needed
                }
              }
            }
          }

          # Security Context
          dynamic "security_context" {
            for_each = lookup(pipeline.value, "security_context", null) != null ? [pipeline.value.security_context] : []
            content {
              dynamic "processor" {
                for_each = lookup(security_context.value, "processors", [])
                content {
                  dynamic "security_context_processor" {
                    for_each = processor.value.type == "security_context_processor" ? [processor.value] : []
                    content {
                      description = lookup(security_context_processor.value, "description", null)
                      enabled     = lookup(security_context_processor.value, "enabled", true)
                      id          = security_context_processor.value.id
                      matcher     = security_context_processor.value.matcher
                      dynamic "value" {
                        for_each = lookup(security_context_processor.value, "value", [])
                        content {
                          type     = value.value.type
                          field     = value.value.type == "field" ? value.value.field : null
                          constant  = value.value.type == "constant" ? value.value.constant : null
                        }
                      }
                    }
                  }
                  # Add other processor types as needed...
                }
              }
            }
          }

          # Storage
          dynamic "storage" {
            for_each = lookup(pipeline.value, "storage", null) != null ? [pipeline.value.storage] : []
            content {
              catch_all_bucket_name = lookup(storage.value, "catch_all_bucket_name", null)
              dynamic "processor" {
                for_each = lookup(storage.value, "processors", [])
                content {
                  dynamic "bucket_assignment_processor" {
                    for_each = processor.value.type == "bucket_assignment_processor" ? [processor.value] : []
                    content {
                      description = lookup(bucket_assignment_processor.value, "description", null)
                      enabled     = lookup(bucket_assignment_processor.value, "enabled", true)
                      bucket_name = bucket_assignment_processor.value.bucket_name
                      id          = bucket_assignment_processor.value.id
                      matcher     = bucket_assignment_processor.value.matcher
                    }
                  }
                  dynamic "no_storage_processor" {
                    for_each = processor.value.type == "no_storage_processor" ? [processor.value] : []
                    content {
                      description = lookup(no_storage_processor.value, "description", null)
                      enabled     = lookup(no_storage_processor.value, "enabled", true)
                      id          = no_storage_processor.value.id
                      matcher     = no_storage_processor.value.matcher
                    }
                  }
                  # Add other storage processor types as needed
                }
              }
            }
          }

        }
      }
  }

  dynamic "routing" {
    for_each = lookup(each.value, "routing", [])
    content {
      dynamic "entry" {
        for_each = [routing.value]
        content {
          enabled     = lookup(entry.value, "enabled", true)
          matcher     = entry.value.matcher
          note        = lookup(entry.value, "note", null)
          pipeline_id = entry.value.pipeline_id
        }
      }
    }
  }

  depends_on = [ dynatrace_platform_bucket.teambuckets ]
}

resource "dynatrace_openpipeline_logs" "logsonly" {
  for_each = length(local.openpipeline_logs) > 0 ? { for idx, p in local.openpipeline_logs : tostring(idx) => p } : {}
  
  endpoints {
    dynamic "endpoint" {
      for_each = lookup(each.value, "endpoints", [])
      content {
        enabled        = lookup(endpoint.value, "enabled", true)
        default_bucket = lookup(endpoint.value, "default_bucket", null)
        display_name   = lookup(endpoint.value, "display_name", null)
        segment        = lookup(endpoint.value, "segment", null)
        dynamic "routing" {
          for_each = [lookup(endpoint.value, "routing", {})]
          content {
            type        = routing.value.type
            pipeline_id = lookup(routing.value, "pipeline_id", null)
          }
        }
      }
    }
  }

  pipelines {
    dynamic "pipeline" {
      for_each = lookup(each.value, "pipelines", [])
      content {
        enabled      = lookup(pipeline.value, "enabled", true)
        display_name = lookup(pipeline.value, "display_name", null)
        id           = pipeline.value.id

        # Processing
        dynamic "processing" {
          for_each = lookup(pipeline.value, "processing", null) != null ? [pipeline.value.processing] : []
          content {
            dynamic "processor" {
              for_each = lookup(processing.value, "processors", [])
              content {
                dynamic "fields_add_processor" {
                  for_each = processor.value.type == "fields_add_processor" ? [processor.value] : []
                  content {
                    description = lookup(fields_add_processor.value, "description", null)
                    enabled     = lookup(fields_add_processor.value, "enabled", true)
                    id          = fields_add_processor.value.id
                    matcher     = fields_add_processor.value.matcher
                    dynamic "field" {
                      for_each = lookup(fields_add_processor.value, "fields", [])
                      content {
                        name  = field.value.name
                        value = field.value.value
                      }
                    }
                  }
                }

                dynamic "dql_processor" {
                  for_each = processor.value.type == "dql_processor" ? [processor.value] : []
                  content {
                    description = lookup(dql_processor.value, "description", null)
                    enabled     = lookup(dql_processor.value, "enabled", true)
                    dql_script  = dql_processor.value.dql_script
                    id          = dql_processor.value.id
                    matcher     = dql_processor.value.matcher
                  }
              }
                # Add other processor types as needed
              }
            }
          }
        }

        # Data Extraction
        dynamic "data_extraction" {
          for_each = lookup(pipeline.value, "data_extraction", null) != null ? [pipeline.value.data_extraction] : []
          content {
            dynamic "processor" {
              for_each = lookup(data_extraction.value, "processors", [])
              content {
                dynamic "davis_event_extraction_processor" {
                  for_each = processor.value.type == "davis_event_extraction_processor" ? [processor.value] : []
                  content {
                    description = lookup(davis_event_extraction_processor.value, "description", null)
                    enabled     = lookup(davis_event_extraction_processor.value, "enabled", true)
                    id          = davis_event_extraction_processor.value.id
                    matcher     = davis_event_extraction_processor.value.matcher
                    dynamic "properties" {
                      for_each = lookup(davis_event_extraction_processor.value, "properties", [])
                      content {
                        key   = properties.value.key
                        value = properties.value.value
                      }
                    }
                  }
                }
                # Add other data_extraction processor types as needed
              }
            }
          }
        }

        # Metric Extraction
        dynamic "metric_extraction" {
          for_each = lookup(pipeline.value, "metric_extraction", null) != null ? [pipeline.value.metric_extraction] : []
          content {
            dynamic "processor" {
              for_each = lookup(metric_extraction.value, "processors", [])
              content {
                dynamic "value_metric_extraction_processor" {
                  for_each = processor.value.type == "value_metric_extraction_processor" ? [processor.value] : []
                  content {
                    description = lookup(value_metric_extraction_processor.value, "description", null)
                    enabled     = lookup(value_metric_extraction_processor.value, "enabled", true)
                    dimensions  = lookup(value_metric_extraction_processor.value, "dimensions", null)
                    field       = lookup(value_metric_extraction_processor.value, "field", null)
                    id          = value_metric_extraction_processor.value.id
                    matcher     = value_metric_extraction_processor.value.matcher
                    metric_key  = value_metric_extraction_processor.value.metric_key
                  }
                }
                dynamic "counter_metric_extraction_processor" {
                  for_each = processor.value.type == "counter_metric_extraction_processor" ? [processor.value] : []
                  content {
                    description = lookup(counter_metric_extraction_processor.value, "description", null)
                    enabled     = lookup(counter_metric_extraction_processor.value, "enabled", true)
                    id          = counter_metric_extraction_processor.value.id
                    matcher     = counter_metric_extraction_processor.value.matcher
                    metric_key  = counter_metric_extraction_processor.value.metric_key
                  }
                }
                # Add other metric_extraction processor types as needed
              }
            }
          }
        }

        # Security Context
        dynamic "security_context" {
          for_each = lookup(pipeline.value, "security_context", null) != null ? [pipeline.value.security_context] : []
          content {
            dynamic "processor" {
              for_each = lookup(security_context.value, "processors", [])
              content {
                dynamic "security_context_processor" {
                  for_each = processor.value.type == "security_context_processor" ? [processor.value] : []
                  content {
                    description = lookup(security_context_processor.value, "description", null)
                    enabled     = lookup(security_context_processor.value, "enabled", true)
                    id          = security_context_processor.value.id
                    matcher     = security_context_processor.value.matcher
                    dynamic "value" {
                      for_each = lookup(security_context_processor.value, "value", [])
                      content {
                        type     = value.value.type
                        field     = value.value.type == "field" ? value.value.field : null
                        constant  = value.value.type == "constant" ? value.value.constant : null
                      }
                    }
                  }
                }
              }
            }
          }
        }

        # Storage
        dynamic "storage" {
          for_each = lookup(pipeline.value, "storage", null) != null ? [pipeline.value.storage] : []
          content {
            catch_all_bucket_name = lookup(storage.value, "catch_all_bucket_name", null)
            dynamic "processor" {
              for_each = lookup(storage.value, "processors", [])
              content {
                dynamic "bucket_assignment_processor" {
                  for_each = processor.value.type == "bucket_assignment_processor" ? [processor.value] : []
                  content {
                    description = lookup(bucket_assignment_processor.value, "description", null)
                    enabled     = lookup(bucket_assignment_processor.value, "enabled", true)
                    bucket_name = bucket_assignment_processor.value.bucket_name
                    id          = bucket_assignment_processor.value.id
                    matcher     = bucket_assignment_processor.value.matcher
                  }
                }
                dynamic "no_storage_processor" {
                  for_each = processor.value.type == "no_storage_processor" ? [processor.value] : []
                  content {
                    description = lookup(no_storage_processor.value, "description", null)
                    enabled     = lookup(no_storage_processor.value, "enabled", true)
                    id          = no_storage_processor.value.id
                    matcher     = no_storage_processor.value.matcher
                  }
                }
                # Add other storage processor types as needed
              }
            }
          }
        }
      }


    }
  }

  dynamic "routing" {
    for_each = lookup(each.value, "routing", [])
    content {
      dynamic "entry" {
        for_each = [routing.value]
        content {
          enabled     = lookup(entry.value, "enabled", true)
          matcher     = entry.value.matcher
          note        = lookup(entry.value, "note", null)
          pipeline_id = entry.value.pipeline_id
        }
      }
    }
  }

  depends_on = [ dynatrace_platform_bucket.teambuckets ]
}


#endregion "open pipelines"

#region "segments"
resource "dynatrace_segment" "this" {
  for_each = { for s in try(local.config.segments, []) : s.name => s }

  name        = each.value.name
  description = lookup(each.value, "description", null)
  is_public   = lookup(each.value, "is_public", false)

  dynamic "includes" {
    for_each = lookup(each.value, "includes", null) != null ? [each.value.includes] : []
    content {
      dynamic "items" {
        for_each = [
          for item in lookup(includes.value, "items", []): item if lookup(item, "data_object", null) != null && trim(item.data_object, " ") != ""
        ]
        content {
          data_object = items.value.data_object
          filter = (
            startswith(items.value.filter, var.FILE_PREFIX) && length(items.value.filter) > length(var.FILE_PREFIX)
            ? file(substr(items.value.filter, length(var.FILE_PREFIX), -1))
            : lookup(items.value, "filter", null)
          )
          dynamic "relationship" {
            for_each = lookup(items.value, "relationship", null) != null ? [items.value.relationship] : []
            content {
              name   = relationship.value.name
              target = relationship.value.target
            }
          }
        }
      }
    }
  }
}
#endregion "segments"