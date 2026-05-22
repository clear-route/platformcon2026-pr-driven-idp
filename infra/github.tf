resource "github_repository_webhook" "this" {
  repository = "platformcon2026-pr-driven-idp"

  configuration {
    url          = "https://argocd.dev.clearroute.io/api/webhook"
    content_type = "json"
  }

  events = ["push"]
}
