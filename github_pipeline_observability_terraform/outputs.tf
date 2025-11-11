### Pipelines

output "events_sdlc_pipelines_github_job_pipeline_id" {
  description = "The ID of the SDLC events GitHub job pipeline"
  value = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_github_job.id
}

output "events_sdlc_pipelines_github_pull_request_pipeline_id" {
  description = "The ID of the SDLC events GitHub pull request pipeline"
  value = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_github_pull_request.id
}

output "events_sdlc_pipelines_github_workflow_pipeline_id" {
  description = "The ID of the SDLC events GitHub workflow pipeline"
  value = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_github_workflow.id
}
