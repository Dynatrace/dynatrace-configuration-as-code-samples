resource "dynatrace_openpipeline_v2_events_sdlc_routing" "events_sdlc_global_routing_table" {
  routing_entries {
    routing_entry {
      enabled       = true
      pipeline_type = "custom"
      matcher       = <<-DQL
        object_kind == "pipeline"
      DQL
      description   = "Route all GitLab events into workflow pipeline (v2)"
      pipeline_id   = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_pipeline.id
    }
    routing_entry {
      enabled       = true
      pipeline_type = "custom"
      matcher       = <<-DQL
        object_kind == "build"
      DQL
      description   = "Route all GitLab events to job pipeline (v2)"
      pipeline_id   = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_job.id
    }
    routing_entry {
      enabled       = true
      pipeline_type = "custom"
      matcher       = <<-DQL
        object_kind == "merge_request"
      DQL
      description   = "Route all GitLab events into merge request pipeline (v2)"
      pipeline_id   = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_merge_request.id
    }
    routing_entry {
      enabled       = true
      pipeline_type = "custom"
      matcher       = <<-DQL
        object_kind == "deployment"
      DQL
      description   = "Route all GitLab events into deployment pipeline (v2)"
      pipeline_id   = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_deployment.id
    }
    routing_entry {
      enabled       = true
      pipeline_type = "custom"
      matcher       = <<-DQL
        object_kind == "release"
      DQL
      description   = "Route all GitLab events into release pipeline (v2)"
      pipeline_id   = dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_release.id
    }
  }
  depends_on = [
    dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_deployment,
    dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_job,
    dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_merge_request,
    dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_pipeline,
    dynatrace_openpipeline_v2_events_sdlc_pipelines.events_sdlc_pipeline_gitlab_release
  ]
}
