### Pipelines

output "events_sdlc_pipelines_gitlab_job_pipeline_id" {
  description = "The ID of the SDLC events Gitlab job pipeline"
  value = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_job.id
}

output "events_sdlc_pipelines_gitlab_release_pipeline_id" {
  description = "The ID of the SDLC events Gitlab release pipeline"
  value = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_release.id
}

output "events_sdlc_pipelines_gitlab_merge_request_pipeline_id" {
  description = "The ID of the SDLC events Gitlab merge request pipeline"
  value = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_merge_request.id
}

output "events_sdlc_pipelines_gitlab_pipeline_pipeline_id" {
  description = "The ID of the SDLC events Gitlab workflow pipeline"
  value = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_pipeline.id
}

output "events_sdlc_pipelines_gitlab_deployment_pipeline_id" {
  description = "The ID of the SDLC events Gitlab deployment pipeline"
  value = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_deployment.id
}
