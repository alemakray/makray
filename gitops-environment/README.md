# GitOps environment scaffold

Kustomize-first GitOps skeleton that assumes:
- A tools cluster runs Argo CD + ApplicationSet controller.
- Argo CD has cluster secrets/aliases: `cluster-dev` (dev cluster) and `cluster-prd` (prod cluster).
- You want per-env appsets and per-env addons, bootstrapped by an app-of-apps.

## Repo layout (what goes where)
- `apps/sample-service/base/` – environment-agnostic Deployment/Service with probes, resources, seccomp, non-root defaults.
- `apps/sample-service/overlays/{dev,prod}/` – per-env knobs (namespace `<app>-<env>`, replicas, labels, image tags).
- `clusters/{dev,prd}/appsets/apps-{dev,prd}.yaml` – ApplicationSets. They watch `apps/*/overlays/{dev|prod}` and create an Argo CD Application per overlay automatically, targeting `cluster-dev`/`cluster-prd`.
- `addons/{dev,prd}/` – Per-cluster addons (Istio, kube-prometheus-stack, External Secrets, Trivy, and a placeholder external-secret-stores app). Each file already targets the correct cluster alias.
- `addons/external-secrets-stores/{dev,prd}/` – Empty folders to hold your SecretStores/ExternalSecrets per cluster.
- `clusters/{dev,prd}/` – Kustomizations that pull that cluster’s appset and addons.
- `bootstrap/{dev,prd}/` – App-of-apps you apply from the tools cluster to let Argo CD pull the rest.

## Prep (one-time)
1) Update repo URLs and revisions:  
   - `clusters/{dev,prd}/appsets/apps-*.yaml`  
   - `clusters/{dev,prd}/addons.yaml`  
   - `addons/{dev,prd}/*.yaml` (including external-secret-stores)  
   - `bootstrap/{dev,prd}/app-of-apps.yaml`
2) In Argo CD, ensure cluster aliases exist: `cluster-dev`, `cluster-prd`.

## Bootstrap flows (run from tools-cluster context)
- Dev cluster: `kubectl apply -k gitops-environment/bootstrap/dev`
- Prod cluster: `kubectl apply -k gitops-environment/bootstrap/prd`
The app-of-apps will register the cluster kustomization, which includes the env appset and env addons.

## Adding an application
1) Create a base: `apps/<app>/base/` with manifests and a `kustomization.yaml`.  
2) Add overlays: `apps/<app>/overlays/dev` and `/prod` with namespace `<app>-dev`/`<app>-prod` and any env-specific patches.  
3) Commit. The ApplicationSet in `clusters/{dev,prd}/appsets/apps-*.yaml` will detect `apps/<app>/overlays/<env>` and create Argo CD Applications in the right cluster automatically.

## Managing addons
- Dev addons live in `addons/dev/*.yaml` (Istio, monitoring stack, External Secrets operator, Trivy, external-secret-stores).  
- Prod addons live in `addons/prd/*.yaml`.  
- Secret stores: add your `SecretStore`/`ClusterSecretStore`/`ExternalSecret` manifests under `addons/external-secrets-stores/{dev,prd}/` and they will sync via the `external-secret-stores` Application in each env.

## Security and hygiene
- Use pinned image tags and signed images where possible; rotate any leaked credentials.  
- External Secrets operator is included to avoid storing secrets in Git; populate only references to your real secret backends.  
- Istio install is minimal; harden mTLS/policies as needed.  
- Helm chart versions here are examples—align to your approved versions before applying.

## Validation
- Install `kustomize` locally and render to verify:  
  `kustomize build gitops-environment/bootstrap/dev` and `.../bootstrap/prd`  
- After repo URLs are set and aliases exist, Argo CD should sync automatically; check Argo CD UI/CLI for status.

## Notes
- Favor immutable tags and signed images; rotate credentials regularly.  
- Kustomize keeps base manifests reusable; overlays prevent env-specific config from drifting into base.  
- Extend by adding more overlays, or AppSets if you need fleet-style rollouts.
