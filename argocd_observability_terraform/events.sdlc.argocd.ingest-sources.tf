resource "dynatrace_openpipeline_v2_events_sdlc_ingestsources" "events_sdlc_ingest_sources_argocd" {
  display_name   = local.ingest_source_display_name
  path_segment   = local.ingest_source_path_segment
  default_bucket = "default_events"
  source_type    = "http"
  enabled        = true
  processing {
    processors {
      processor {
        description = "Add event properties"
        type        = "fieldsAdd"
        enabled     = true
        id          = "processor_add_event_properties"
        matcher     = "true"
        fields_add {
          fields {
            field {
              name  = "event.kind"
              value = "SDLC_EVENT"
            }
            field {
              name  = "event.provider"
              value = local.sdlc_event_provider
            }
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
              value = "deployment"
            }
          }
        }
      }
      processor {
        description = "Add event.id if not set"
        type        = "dql"
        enabled     = true
        id          = "processor_add_event_id_if_not_set"
        matcher     = "isNull(event.id)"
        dql {
          script = "fieldsAdd event.id = hashSha1(concat(toString(toLong(now())), toString(RANDOM())))"
        }
      }
    }
  }
  static_routing {
    pipeline_id   = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_argocd_application.id
    pipeline_type = "custom"
  }

  depends_on = [
    dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_argocd_application
  ]
}
