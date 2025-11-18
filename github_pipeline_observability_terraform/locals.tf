locals {
  sdlc_event_version = "0.1.0"
  sdlc_event_provider = "github.com"

  ingest_source_display_name = "GitHub"
  ingest_source_path_segment = "github"

  job_pipeline_display_name = "GitHub Job (v2)"
  job_pipeline_custom_id  = "pipeline_github_job_v2"

  workflow_pipeline_display_name = "GitHub Workflow (v2)"
  workflow_pipeline_custom_id = "pipeline_github_pipeline_v2"

  pull_request_pipeline_display_name = "GitHub Pull Request (v2)"
  pull_request_pipeline_custom_id = "pipeline_github_pull_request_v2"
}
