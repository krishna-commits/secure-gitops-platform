# secure-gitops-platform

[![CI](https://github.com/krishna-commits/secure-gitops-platform/actions/workflows/ci.yml/badge.svg)](https://github.com/krishna-commits/secure-gitops-platform/actions/workflows/ci.yml)

Every push spins up a real Kubernetes cluster in CI, installs Kyverno, deploys the hardened demo app, and **proves the admission policies reject privileged pods and `:latest` images**. If the guardrails stop working, the badge goes red.

A reference implementation of a **secure, GitOps-driven Kubernetes platform**: every change is declared in Git, gated by security checks in CI, reconciled by ArgoCD, and enforced at admission by policy.

It's the working companion to the reference architectures on [krishnaneupane.com/architecture](https://krishnaneupane.com/architecture/gitops-k8s).

```
 Git (this repo) ──► CI security gates ──► ArgoCD (app-of-apps) ──► Kubernetes
                      │                      │                        │
                      ├ terraform validate   ├ auto-sync + self-heal  ├ Kyverno admission policies
                      ├ trivy config scan    └ drift reverted         ├ hardened workloads
                      ├ kubeconform                                   └ default-deny networking
                      └ gitleaks
```

## What's inside

| Path | Purpose |
|---|---|
| `kind/` | Local cluster definition for trying everything on a laptop |
| `bootstrap/` | ArgoCD install values and the root (app-of-apps) Application |
| `gitops/apps/` | ArgoCD Applications: Kyverno, policies, demo workload |
| `policies/` | Kyverno `ClusterPolicy` set: no privileged pods, non-root, resource limits, no `:latest` |
| `charts/demo-app/` | A hardened Helm chart: read-only root FS, dropped capabilities, NetworkPolicy, probes |
| `infra/aws/` | Terraform for a production-style VPC + EKS cluster (community modules, pinned) |
| `.github/workflows/` | CI: Terraform validation, IaC misconfiguration scan, manifest validation, secret scan |

## Quick start (local, ~5 minutes)

Requirements: Docker, [kind](https://kind.sigs.k8s.io/), `kubectl`, `helm`.

```sh
make up        # create the kind cluster and install ArgoCD
make bootstrap # hand control to GitOps: ArgoCD installs Kyverno, policies, and the demo app
make status    # watch the Applications sync
make ui        # port-forward the ArgoCD UI to https://localhost:8080
```

Before `make bootstrap`, set `repoURL` in `bootstrap/root-app.yaml` and `gitops/apps/*.yaml` to your fork.

### See the guardrails work

```sh
make test-policies
```

This tries to apply a privileged pod and a `:latest` image; Kyverno rejects both at admission.

## Design decisions

- **Pull, don't push.** CI never holds cluster credentials. ArgoCD pulls desired state from Git.
- **Self-heal on.** Manual `kubectl edit` changes are reverted; the reviewed state is the running state.
- **Policy at admission, not just in CI.** CI checks can be bypassed; admission control can't.
- **Secure by default.** The demo chart ships hardened, so the paved road is also the secure road.
- **Pinned everything.** Chart versions, Terraform module versions, and image tags are explicit.

## Production notes

`infra/aws/` provisions a private-subnet EKS cluster with managed node groups. Secrets should come from a manager such as HashiCorp Vault or AWS Secrets Manager (via External Secrets), never from this repository.

## License

Choose a license (MIT or Apache-2.0 are common for reference repos) before publishing.

---

Built by [Krishna Neupane](https://krishnaneupane.com), Senior DevSecOps Engineer.
