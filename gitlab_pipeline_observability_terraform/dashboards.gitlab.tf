resource "dynatrace_document" "dashboard_gitlab_deployments" {
  type      = "dashboard"
  name      = "GitLab Deployments"
  custom_id = "gitlab-deployments"
  content = file("${path.module}/dashboards/gitlab.deployments.json")
}

resource "dynatrace_document" "dashboard_gitlab_pipeline_pulse" {
  type      = "dashboard"
  name      = "GitLab Pipeline Pulse"
  custom_id = "gitlab-pipeline-pulse"
  content = file("${path.module}/dashboards/gitlab.pipeline.json")
}

resource "dynatrace_document" "dashboard_gitlab_merge_requests" {
  type      = "dashboard"
  name      = "GitLab Merge Requests"
  custom_id = "gitlab-merge-requests"
  content = file("${path.module}/dashboards/gitlab.merge_request.json")
}
