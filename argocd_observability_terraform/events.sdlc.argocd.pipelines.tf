resource "dynatrace_openpipeline_v2_events_sdlc_pipelines" "events_sdlc_pipeline_argocd_application" {
  display_name = local.app_pipeline_display_name
  custom_id    = local.app_pipeline_custom_id
  processing {
    processors {
      processor {
        description = "Add ArgoCD deployment properties"
        type        = "dql"
        enabled     = true
        id          = "processor_add_argocd_deployment_properties"
        matcher     = "isNotNull(app)"
        dql {
          script = <<-DQL
            parse app,
              "JSON{
                JSON{
                  JSON{
                    STRING:phase,
                    STRING:finishedAt,
                    STRING:startedAt,
                    JSON{
                      JSON{
                        STRING:targetRevision,
                        STRING:repoURL
                      }:source
                    }:syncResult,
                    JSON{
                      JSON{
                        STRING:revision
                      }:sync
                    }:operation,
                    STRING:message
                  }:operationState,
                  JSON{
                    STRING:revision,
                    JSON{
                      JSON{
                        STRING:namespace,
                        STRING:server,
                        STRING:name
                      }:destination
                    }:comparedTo,
                    STRING:status
                  }:sync,
                  JSON{
                    STRING:status
                  }:health,
                  JSON[]:conditions,
                  STRING:reconciledAt
                }:status,
                JSON{
                  STRING:uid,
                  JSON:labels,
                  STRING:name
                }:metadata,
                JSON{
                  STRING:project
                }:spec
              }:app_json"
            | fieldsFlatten app_json, fields:{ status, metadata, spec }

            | fieldsAdd event.status = if(lower(status[operationState][phase]) == "running", "started", else: "finished")
            | fieldsAdd duration = if((status[operationState][finishedAt] > status[operationState][startedAt]) and isNotNull(status[operationState][finishedAt]), toTimestamp(status[operationState][finishedAt]) - toTimestamp(status[operationState][startedAt]), else: toDuration(0))
            | fieldsAdd start_time = status[operationState][startedAt]
            | fieldsAdd end_time = status[operationState][finishedAt]

            | fieldsAdd task.id = hashSha1(concat(toString(toLong(now())), toString(RANDOM())))
            | fieldsAdd task.name = "ArgoCD Deployment"
            | fieldsAdd task.outcome = lower(status[operationState][phase])

            | fieldsAdd vcs.ref.base.name = status[operationState][syncResult][source][targetRevision]
            | fieldsAdd vcs.ref.base.revision = status[operationState][operation][sync][revision]
            | fieldsAdd vcs.repository.url.full = status[operationState][syncResult][source][repoURL]

            | fieldsAdd cicd.deployment.service.id = metadata[uid]
            | fieldsAdd cicd.deployment.id = status[sync][revision]
            | fieldsAdd cicd.deployment.name = metadata[name]
            | fieldsAdd cicd.deployment.namespace = status[sync][comparedTo][destination][namespace]
            | fieldsAdd cicd.deployment.server.url.full = if(isNotNull(status[sync][comparedTo][destination][server]), status[sync][comparedTo][destination][server], else: if(isNotNull(status[sync][comparedTo][destination][name]), status[sync][comparedTo][destination][name]))

            | fieldsAdd argocd.app.health.status = lower(status[health][status])
            | fieldsAdd argocd.app.conditions = status[conditions]
            | fieldsAdd argocd.app.reconciliation.time =  toTimestamp(status[reconciledAt])
            | fieldsAdd argocd.sync.status = lower(status[sync][status])
            | fieldsAdd argocd.sync.operation_state.outcome = lower(status[operationState][message])

            | fieldsAdd argocd.app.project.name = spec[project]

            | fieldsAdd argocd.app.name = metadata[labels][app]
            | fieldsAdd argocd.app.stage = metadata[labels][stage]
            | fieldsAdd argocd.app.owner = metadata[labels][owner]
            | fieldsAdd argocd.app.version = metadata[labels][version]

            | fieldsAdd cicd.deployment.release_stage = argocd.app.stage

            | fieldsRemove app_json, status, metadata, spec
          DQL
        }
      }
      processor {
        description = "Clean up"
        type        = "fieldsRemove"
        enabled     = true
        id          = "processor_clean_up"
        matcher     = "true"
        fields_remove {
          fields = ["app"]
        }
      }
    }
  }
  metric_extraction {
    processors {
      processor {
        description = "Number of finished SDLC tasks"
        type        = "counterMetric"
        enabled     = true
        id          = "metric_processor_number_of_finished_sdlc_tasks"
        matcher     = "event.status == \"finished\""
        counter_metric {
          metric_key = "events.sdlc.finished_tasks"
          dimensions {
            dimension {
              source_field_name = "event.category"
            }
            dimension {
              source_field_name = "event.type"
            }
            dimension {
              source_field_name = "event.provider"
            }
            dimension {
              source_field_name = "event.status"
            }
            dimension {
              source_field_name = "vcs.repository.ref.name"
            }
            dimension {
              source_field_name = "cicd.pipeline.name"
            }
          }
        }
      }
      processor {
        description = "Number of all SDLC tasks"
        type        = "counterMetric"
        enabled     = true
        id          = "metric_processor_number_of_all_sdlc_tasks"
        matcher     = "true"
        counter_metric {
          metric_key = "events.sdlc.tasks"
          dimensions {
            dimension {
              source_field_name = "event.category"
            }
            dimension {
              source_field_name = "event.type"
            }
            dimension {
              source_field_name = "event.provider"
            }
            dimension {
              source_field_name = "event.status"
            }
            dimension {
              source_field_name = "vcs.repository.ref.name"
            }
            dimension {
              source_field_name = "cicd.pipeline.name"
            }
            dimension {
              source_field_name = "actor.geo.country.name"
            }
          }
        }
      }
      processor {
        description = "Duration of finished SDLC tasks"
        type        = "valueMetric"
        enabled     = true
        id          = "metric_processor_duration_of_finished_sdlc_tasks"
        matcher     = "event.status == \"finished\""
        value_metric {
          field      = "duration"
          metric_key = "events.sdlc.task_duration"
          dimensions {
            dimension {
              source_field_name = "event.category"
            }
            dimension {
              source_field_name = "event.type"
            }
            dimension {
              source_field_name = "event.provider"
            }
            dimension {
              source_field_name = "event.status"
            }
            dimension {
              source_field_name = "vcs.repository.ref.name"
            }
            dimension {
              source_field_name = "cicd.pipeline.name"
            }
          }
        }
      }
    }
  }
}
