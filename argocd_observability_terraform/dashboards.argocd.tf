resource "dynatrace_document" "dashboard_argocd_application_lifecycle" {
  type      = "dashboard"
  name      = "ArgoCD Application Lifecycle (tf)"
  custom_id = "argocd-application-lifecycle"
  content = file("${path.module}/dashboards/argocd_app_lifecycle_observability.json")
}

resource "dynatrace_document" "dashboard_argocd_platform_observability" {
  type      = "dashboard"
  name      = "ArgoCD Platform Observability (tf)"
  custom_id = "argocd-platform-observability"
  content = file("${path.module}/dashboards/argocd_platform_observability.json")
}
