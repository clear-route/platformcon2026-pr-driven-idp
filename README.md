# Notes
## Demo1 Infra Provisioning
- App Onboarding
- customer creates PR (branch name == $app name)
- Atlantis triggered
- Platform Ops runs plan/apply to provision infra (IAM roles, ECR, repo, ...)
- customer drops code in $repo -> images are published

## Demo2 Onboarding Preview
- customer updates PR with manifests
- adds onboarding label
- argocd onboarding pr generator picks up branch and deploys it
- customer can review and update as needed
-

## Demo3 PR preview envs
- customer provides PR preview manifests
- opens PR in app repo
- labels PR with preview
- preview app is deployed, PR has been commented


# Code
## Demo1
- TF code that is tracked in atlantis that creates ECR, IAM pols, and even the repo
- perhaps copy paste the app in to its directory. code can just be a simple frontend that prints the version and an env var
- commit back -> publish image

## Demo2
- demo-app dir with kustomize overlays
- constellation argocd app (in this repo as well) that watches the repo
- deploys it

## Demo3
- add preview overlay
- preview appset in this repo as well


# todos
- get PR comments working https://github.com/clear-route/constellation-iac/blob/main/applications/management/argocd-notifications/notifications.yaml
- argocd diff preview
