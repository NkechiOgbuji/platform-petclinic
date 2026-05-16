# Argo CD Install Fallback

This folder contains a fallback Kustomize layer for installing Argo CD directly
from vendored manifests.

## Important

The normal path for this repository is Terraform-managed Argo CD through the
`terraform/modules/addons` module and the upstream `argo-cd` Helm chart.

Use this fallback only for a cluster that is not already managing Argo CD with
the Terraform Helm release.

## Contents

- `namespace.yaml`: creates the `argocd` namespace.
- `install.yaml`: vendored Argo CD install manifest.
- `rbac.yaml`: patches `argocd-rbac-cm` with readonly defaults, developer
  permissions for dev sync, and admin/developer group mappings.
- `workload-selectors.yaml`: patches Argo CD workload selectors and labels for
  compatibility with the release labels expected in this repo.
- `kustomization.yaml`: ties the layer together.

## Apply

```bash
kubectl apply --server-side --force-conflicts -k k8s/argocd/install
```

## Verify

```bash
kubectl get pods -n argocd
kubectl rollout status deployment/argocd-server -n argocd
kubectl rollout status statefulset/argocd-application-controller -n argocd
```