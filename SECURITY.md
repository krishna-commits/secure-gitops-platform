# Security

This is a reference implementation. If you find a security issue in it, please report it privately through
[krishnaneupane.com/contact](https://krishnaneupane.com/contact) rather than opening a public issue.

## Controls demonstrated

| Layer | Control |
|---|---|
| Source | Secret scanning (gitleaks) on every push |
| IaC | `terraform validate` and Trivy misconfiguration scanning, failing on HIGH/CRITICAL |
| Manifests | Schema validation (kubeconform) for workloads, policies, and ArgoCD Applications |
| Delivery | Pull-based GitOps; CI holds no cluster credentials; drift is self-healed |
| Admission | Kyverno: no privileged pods, non-root only, resource limits required, no `:latest` |
| Workload | Read-only root FS, dropped capabilities, seccomp, no service-account token, default-deny NetworkPolicy |
| Cloud | Private EKS API by default, IMDSv2 only, VPC flow logs, control-plane audit logging |
