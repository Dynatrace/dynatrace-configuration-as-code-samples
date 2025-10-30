locals {
  ingest_source_display_name = "Gitlab"
  ingest_source_path_segment = "gitlab"

  job_pipeline_display_name = "Gitlab Job"
  job_pipeline_custom_id  = "pipeline_gitlab_job_v2"

  workflow_pipeline_display_name = "Gitlab Pipeline"
  workflow_pipeline_custom_id = "pipeline_gitlab_pipeline_v2"

  merge_request_pipeline_display_name = "Gitlab Merge Request"
  merge_request_pipeline_custom_id = "pipeline_gitlab_merge_request_v2"

  release_pipeline_display_name = "Gitlab Release"
  release_pipeline_custom_id = "pipeline_gitlab_release_v2"

  deployment_pipeline_display_name = "Gitlab Deployment"
  deployment_pipeline_custom_id = "pipeline_gitlab_deployment_v2"
}
