resource "dynatrace_openpipeline_v2_events_sdlc_ingestsources" "events_sdlc_ingest_sources_gitlab" {
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
        matcher     = <<-DQL
          object_kind == "pipeline"
        DQL
        description = "Add pipeline run properties"
        id          = "processor_add_pipeline_run_properties"
        enabled     = true
        fields_add {
          fields {
            field {
              name  = "event.version"
              value = "0.1.0"
            }
            field {
              name  = "event.provider"
              value = "gitlab"
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
        matcher     = <<-DQL
          object_kind == "build"
        DQL
        description = "Add build task properties"
        id          = "processor_add_build_task_properties"
        enabled     = true
        fields_add {
          fields {
            field {
              name  = "event.version"
              value = "0.1.0"
            }
            field {
              name  = "event.provider"
              value = "gitlab"
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
        matcher     = <<-DQL
          object_kind == "merge_request"
        DQL
        description = "Add change task properties"
        id          = "processor_add_change_task_properties"
        enabled     = true
        fields_add {
          fields {
            field {
              name  = "event.version"
              value = "0.1.0"
            }
            field {
              name  = "event.provider"
              value = "gitlab"
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
      processor {
        type        = "fieldsAdd"
        matcher     = <<-DQL
          object_kind == "deployment"
        DQL
        description = "Add deployment category properties"
        id          = "processor_add_deployment_category_properties"
        enabled     = true
        fields_add {
          fields {
            field {
              name  = "event.version"
              value = "0.1.0"
            }
            field {
              name  = "event.provider"
              value = "gitlab"
            }
            field {
              name  = "event.category"
              value = "task"
            }
            field {
              name  = "event.type"
              value = "deployment"
            }
          }
        }
      }
      processor {
        type        = "fieldsAdd"
        matcher     = <<-DQL
          object_kind == "release"
        DQL
        description = "Add release task properties"
        id          = "processor_add_release_task_properties"
        enabled     = true
        fields_add {
          fields {
            field {
              name  = "event.version"
              value = "0.1.0"
            }
            field {
              name  = "event.provider"
              value = "gitlab"
            }
            field {
              name  = "event.category"
              value = "task"
            }
            field {
              name  = "event.type"
              value = "release"
            }
          }
        }
      }
    }
  }
}