resource "dynatrace_document" "dashboard_github_workflow_pulse" {
  type      = "dashboard"
  name      = "GitHub Workflow Pulse"
  custom_id = "github-workflow-pulse"
  content = file("${path.module}/dashboards/github.workflow_pulse.json")
}

resource "dynatrace_document" "dashboard_github_pull_requests" {
  type      = "dashboard"
  name      = "GitHub Pull Requests"
  custom_id = "github-pull-requests"
  content = file("${path.module}/dashboards/github.pull_requests.json")
}
