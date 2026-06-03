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
5. Review TF Plan & comment `atlantis apply -p PlatformConDemo-Infra`

The demo-app infra (IAM, ECR, ..) is now deployed

# Demo2 - ArgoCD - Application Onboarding
1. Copy the example `frontend` source code for `demo-app` to `applications/demo-app/src/frontend`: `cp -R .templates/demo-app/src/* applications/demo-app/src/.`
2. commit and push: `git add . && git commit -m "demo-app frontend source code" && git push`
3. switch to Github UI and inspect CI workflow # the demo-app frontend preview image has now been build and published
4.  Copy k8s manifests for demo-apps `frontend` to `applications/demo-app/k8s`:

```
cp -R .templates/demo-app/k8s/base applications/demo-app/k8s/base
mkdir -p applications/demo-app/k8s/overlays/{dev,preview}
cp -R .templates/demo-app/k8s/overlays/dev/ applications/demo-app/k8s/overlays/dev/
cp -R .templates/demo-app/k8s/overlays/preview/ applications/demo-app/k8s/overlays/preview/
```

5. change the `newTag` in `applications/demo-app/k8s/overlays/dev/kustomization.yaml` to the one from the Workflow summary:

```
images:
  - name: clearroute/demo-app-frontend
    newName: 799468650620.dkr.ecr.ap-southeast-2.amazonaws.com/demo-app-frontend-preview # was demo-app-frontend-dev
```

6. commit and push: `git add . && git commit -m "demo-app k8s manifests" && git push`
7. label this PR `onboarding`, wait for ArgoCD onboarding PR generator pick it up # this can take a while, to trigger immediately, delete the `platformcon2026-onboarding-appset` appset in the ArgoCDUI in the `platformcondemo`
8. navigate to the ArgoCD demo-app, show the resources and open its URL `https://demo-app-dev.dev.clearroute.io`
9. revert `newName` back to `-dev`
10. merge the PER # Onboarding ArgoCD App will be deleted, Demo-app Dev App will be created and should be uop & running once the image has been published on main

# Demo3 - ArgoCD - Preview Environments
1. `git checkout main && git fetch --all && git pull origin main -r`
2. `git checkout -b demo-app-change`
3. Do any dummy change under `applications/demo-app/src/frontend`
4. commit and push: `git add . && git commit -m "provision demo-app infra" && git push`
5. Open PR with label `preview`
6. Switch to ArgoCD UI, a preview app should have been created
7. navigate to preview URL and show how the branch is shown
8. u can repeat this multiple times and instruct the audience to do so as well
9. Merge

You can show how all preview envs are being destroyed after merge

# Demo4 - ArgoCd - Promoting to PROD
1. `git checkout main && git fetch --all && git pull origin main -r`
2. `git checkout -b demo-app-promote-to-prod`
3. copy prod overlay

```
mkdir -p applications/demo-app/k8s/overlays/prod
cp -R .templates/demo-app/k8s/overlays/dev/ applications/demo-app/k8s/overlays/prod/
```

4. replace ref in prod kustomize prod overlay with latest commit on main
5. replace `newTag` with the short GIT SHA
6. `git add . && git commit -m "promote to prod" && git push`
7. show Argocd Diff preview
8. merge
9. show argocd prod app and UI
