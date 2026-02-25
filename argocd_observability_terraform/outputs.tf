### Pipeline

output "events_sdlc_pipelines_argocd_application_pipeline_id" {
  description = "The ID of the SDLC events pipeline for ArgoCD application"
  value = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_argocd_application.id
}

