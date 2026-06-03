# Deploying an application `demo-app` with a component `frontend`

# Prerequisites
Repo local available:
```bash
> git clone https://github.com/clear-route/platformcon2026-pr-driven-idp.git
```

# Demo1 - Atlantis - Infrastructure Provisioning
1. create branch with name `demo-app`: `git checkout -b demo-app`
2. create directory in `applications`:

```sh
> mkdir -p applications/demo-app/{src,k8s} # application directories (source code * k8s manifests)
> mkdir -p applications/demo-app/src/frontend # component source code directory
> touch applications/demo-app/src/frontend/Dockerfile # create a dummy file so TF picks up the component
```

3. commit & push: `git add . && git commit -m "provision demo-app infra && git push`
4. switch to Github UI, create PR & wait for Atlantis Plan to finish
5. Review TF Plan & comment `atlantis apply -p PlatformConDemo-Infra` # the demo-app infra (IAM, ECR, ..) is now deployed
6. Copy the example `frontend` source code for `demo-app` to `applications/demo-app/src/frontend`: `cp -R .templates/demo-app/src/* applications/demo-app/src/.`
7. commit and push: `git add . && git commit -m "demo-app frontend source code && git push`
# Demo2 - ArgoCD - Application Onboarding
# Demo3 - ArgoCD - Preview Environments
# Demo4 - ArgoCd - Promoting to PROD
