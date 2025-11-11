resource "dynatrace_openpipeline_v2_events_sdlc_ingestsources" "events_sdlc_ingest_sources_github" {
  display_name   = local.ingest_source_display_name
  path_segment   = local.ingest_source_path_segment
  default_bucket = "default_events"
  enabled        = true
  processing {
    processors {
      processor {
        type        = "fieldsAdd"
        matcher     = "isNull(event.kind)"
        description = "Add event.kind if not set"
        id          = "processor_add_event_kind_if_not_set"
        enabled     = true
        fields_add {
          fields {
            field {
              name  = "event.kind"
              value = "SDLC_EVENT"
            }
          }
        }
      }
      processor {
        type        = "fieldsAdd"
        matcher     = "isNull(event.provider)"
        description = "Add event.provider if not set"
        id          = "processor_add_event_provider_if_not_set"
        enabled     = true
        fields_add {
          fields {
            field {
              name  = "event.provider"
              value = local.sdlc_event_provider
            }
          }
        }
      }
      processor {
        type        = "dql"
        matcher     = "isNull(event.id)"
        description = "Add event.id if not set"
        id          = "processor_add_event_id_if_not_set"
        enabled     = true
        dql {
          script = "fieldsAdd event.id = hashSha1(concat(toString(toLong(now())), toString(RANDOM())))"
        }
      }
      processor {
        type        = "fieldsAdd"
        matcher     = "isNotNull(workflow_run)"
        description = "Add pipeline run properties"
        id          = "processor_add_pipeline_run_properties"
        enabled     = true
        fields_add {
          fields {
            field {
              name  = "event.version"
              value = local.sdlc_event_version
            }
            field {
              name  = "event.category"
              value = "pipeline"
            }
            field {
              name  = "event.type"
              value = "run"
            }
          }
        }
      }
      processor {
        type        = "fieldsAdd"
        matcher     = "isNotNull(workflow_job)"
        description = "Add build task properties"
        id          = "processor_add_build_task_properties"
        enabled     = true
        fields_add {
          fields {
            field {
              name  = "event.version"
              value = local.sdlc_event_version
            }
            field {
              name  = "event.category"
              value = "task"
            }
            field {
              name  = "event.type"
              value = "build"
            }
          }
        }
      }
      processor {
        type        = "fieldsAdd"
        matcher     = "isNotNull(pull_request)"
        description = "Add change task properties"
        id          = "processor_add_change_task_properties"
        enabled     = true
        fields_add {
          fields {
            field {
              name  = "event.version"
              value = local.sdlc_event_version
            }
            field {
              name  = "event.category"
              value = "task"
            }
            field {
              name  = "event.type"
              value = "change"
            }
          }
        }
      }
    }
  }
}