resource "dynatrace_openpipeline_v2_events_sdlc_routing" "events_sdlc_global_routing_table" {
  routing_entries {
    routing_entry {
      enabled       = true
      pipeline_type = "custom"
      matcher       = "isNotNull(workflow_run)"
      description   = "Route all GitHub events into workflow pipeline (v2)"
      pipeline_id   = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_github_workflow.id
    }
    routing_entry {
      enabled       = true
      pipeline_type = "custom"
      matcher       = "isNotNull(workflow_job)"
      description   = "Route all GitHub events to job pipeline (v2)"
      pipeline_id   = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_github_job.id
    }
    routing_entry {
      enabled       = true
      pipeline_type = "custom"
      matcher       = "isNotNull(pull_request)"
      description   = "Route all GitHub events into pull request pipeline (v2)"
      pipeline_id   = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_github_pull_request.id
    }
  }
  depends_on = [
    dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_github_job,
    dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_github_pull_request,
    dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_github_workflow,
  ]
}
