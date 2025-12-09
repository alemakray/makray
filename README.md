# makray

DevOps/GitOps portfolio: Azure-first, Kubernetes-native, with Terraform, Argo CD, Kustomize, secure supply chain, monitoring, and cost-aware practices baked in. This repo is structured to demonstrate how I design, bootstrap, and operate multi-environment clusters with strong governance and automation.

## What I focus on
- **Cloud & Infra**: Azure, AKS, Azure DevOps, Terraform (remote state, workspaces), GitHub Actions; experience with OCI/OKE as well.
- **GitOps**: Argo CD (app-of-apps, ApplicationSets), Kustomize overlays, promotion pipelines, drift detection, and policy-as-code.
- **Security**: External Secrets operator, non-root defaults, seccomp, Trivy Operator, signed/immutable images, secret hygiene.
- **Delivery**: CI/CD patterns with GitHub Actions/Azure Pipelines, image automation, blue/green or canary via Istio/gateway mesh.
- **Observability & Cost**: Prometheus/Grafana stack, service monitors, retention tuning; cost-aware sizing and right-sizing signals.
- **Reliability**: Health probes, autoscaling patterns, multi-env parity, automated self-heal/prune via Argo CD.

See `argocd/README.md` for the Argo CD/GitOps scaffold; other files/scripts are for experiments and future IaC/CI/CD examples.

## Why this matters
- Shows how I structure GitOps for multiple clusters/environments with clear separation of concerns.
- Demonstrates security-first defaults (non-root, seccomp, secrets out of Git) and observability baked in.
- Reflects cost and reliability awareness (resource requests/limits, retention settings, autoscaling).
- Provides a repeatable bootstrap story for interviews, POCs, or client-facing demos.
