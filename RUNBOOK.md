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

3. commit & push: `git add . && git commit -m "provision demo-app infra" && git push`
4. switch to Github UI, create PR & wait for Atlantis Plan to finish
5. Review TF Plan & comment `atlantis apply -p PlatformConDemo-Infra` # the demo-app infra (IAM, ECR, ..) is now deployed
6. Copy the example `frontend` source code for `demo-app` to `applications/demo-app/src/frontend`: `cp -R .templates/demo-app/src/* applications/demo-app/src/.`
7. commit and push: `git add . && git commit -m "demo-app frontend source code" && git push`
8. switch to Github UI and inspect CI workflow # the demo-app frontend preview image has now been build and published, go to workflow summary and look at the full image tag
9.  Copy k8s manifests for demo-apps `frontend` to `applications/demo-app/k8s`:

```
cp -R .templates/demo-app/k8s/base applications/demo-app/k8s/base
mkdir -p applications/demo-app/k8s/overlays/{dev,preview}
cp -R .templates/demo-app/k8s/overlays/dev/ applications/demo-app/k8s/overlays/dev/
cp -R .templates/demo-app/k8s/overlays/preview/ applications/demo-app/k8s/overlays/preview/
```

10. change the `newTag` in `applications/demo-app/k8s/overlays/dev/kustomization.yaml` to the one from the Workflow summary:

```
images:
  - name: clearroute/demo-app-frontend
    newName: 799468650620.dkr.ecr.ap-southeast-2.amazonaws.com/demo-app-frontend-preview
    newTag: <SHA>
```

11. commit and push: `git add . && git commit -m "demo-app k8s manifests" && git push`
12. label this PR `onboarding`, wait for ArgoCD onboarding PR generator pick it up # this can take a while, to trigger immediately, delete the `platformcon2026-onboarding-appset` appset in the ArgoCDUI in the `platformcondemo`
13. navigate to the ArgoCD demo-app, show the resources and open its URL `https://demo-app-dev.dev.clearroute.io`
14. merge the PR 


# Demo2 - ArgoCD - Application Onboarding
# Demo3 - ArgoCD - Preview Environments
# Demo4 - ArgoCd - Promoting to PROD
