# External Secrets Raw Manifests

This folder contains raw Kubernetes reference manifests related to External
Secrets.

The active External Secrets Operator and `ClusterSecretStore` are managed by
Terraform in `terraform/modules/addons`.

The raw Kustomize base includes the database and OpenAI `ExternalSecret`
resources. `cluster-secret-store.yaml` is kept as a support reference, but the
overlay kustomizations do not include it because Terraform owns the live
`ClusterSecretStore`.

In the active deployment path, application `ExternalSecret` resources are
rendered by the `helm/petclinic-secrets` chart.