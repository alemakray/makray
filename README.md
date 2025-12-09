# makray

GitOps playground with Argo CD + Kustomize, built to manage two workload clusters (aliases `cluster-dev`, `cluster-prd`) from a tools cluster running Argo CD. The `gitops-environment/` folder holds everything you need to bootstrap, deploy apps per environment, and install core addons.

## What’s inside
- `gitops-environment/apps/` – Sample apps (`app1`, `app2`) with reusable bases and overlays per env (`dev`, `prod`); follow the same pattern for your apps.
- `gitops-environment/clusters/{dev,prd}/` – Per-cluster kustomizations that include that env’s ApplicationSet (`appsets/apps-*.yaml`) and addons.
- `gitops-environment/addons/{dev,prd}/` – Argo CD Applications to install Istio, kube-prometheus-stack (Prometheus/Grafana), External Secrets operator, Trivy, plus an `external-secret-stores` app pointing to folders you can populate with SecretStore/ExternalSecret manifests.
- `gitops-environment/bootstrap/{dev,prd}/` – App-of-apps entrypoints; apply from the tools cluster to let Argo CD pull the rest.
- `gitops-environment/README.md` – Detailed usage guide.

## Assumptions
- Argo CD (with ApplicationSet controller) runs in a tools cluster.
- Argo CD has cluster secrets/aliases: `cluster-dev` (dev cluster), `cluster-prd` (prod cluster).
- You will set your own `repoURL`/`targetRevision` in the manifests before applying.

## Quick start
1) Update repo URLs and revisions in:
   - `gitops-environment/clusters/{dev,prd}/appsets/apps-*.yaml`
   - `gitops-environment/clusters/{dev,prd}/addons.yaml`
   - `gitops-environment/addons/{dev,prd}/*.yaml`
   - `gitops-environment/bootstrap/{dev,prd}/app-of-apps.yaml`
2) From the tools cluster context, bootstrap:
   - Dev: `kubectl apply -k gitops-environment/bootstrap/dev`
   - Prod: `kubectl apply -k gitops-environment/bootstrap/prd`
3) Add apps by creating `apps/<app>/base` + `apps/<app>/overlays/{dev,prod}` (namespaces `<app>-dev` / `<app>-prod`). The env-specific ApplicationSet will auto-create Argo CD Applications in the right cluster.

## Addons and secrets
- Addons are per-env; edit values/versions to match your standards.
- Populate `gitops-environment/addons/external-secrets-stores/{dev,prd}/` with your SecretStore/ExternalSecret manifests; they sync via the `external-secret-stores` app in each env.

## Validation
- Install `kustomize` and render: `kustomize build gitops-environment/bootstrap/dev` (and `.../prd`) after updating repo URLs.
- Check Argo CD UI/CLI to confirm sync once applied.
