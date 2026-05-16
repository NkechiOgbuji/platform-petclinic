# Prod Argo CD Applications

This folder contains the prod Argo CD Applications for Petclinic.

## Behavior

All prod Applications:

- Deploy to namespace `petclinic-prod`.
- Use project `petclinic`.
- Source charts from `helm/petclinic-service`.
- Track `targetRevision: main`.
- Merge `helm-values/prod.yaml` first and the service values file second.
- Use manual sync rather than automated sync.
- Use sync options:
  - `CreateNamespace=true`
  - `ApplyOutOfSyncOnly=true`
  - `PruneLast=true`

## Applications

| Application | Release | Sync wave | Values |
| --- | --- | ---: | --- |
| `config-server-prod` | `config-server` | 0 | `prod.yaml`, `config-server.yaml` |
| `discovery-server-prod` | `discovery-server` | 1 | `prod.yaml`, `discovery-server.yaml` |
| `customers-service-prod` | `customers-service` | 2 | `prod.yaml`, `customers-service.yaml` |
| `vets-service-prod` | `vets-service` | 2 | `prod.yaml`, `vets-service.yaml` |
| `visits-service-prod` | `visits-service` | 2 | `prod.yaml`, `visits-service.yaml` |
| `genai-service-prod` | `genai-service` | 2 | `prod.yaml`, `genai-service.yaml` |
| `api-gateway-prod` | `api-gateway` | 3 | `prod.yaml`, `api-gateway.yaml` |
| `admin-server-prod` | `admin-server` | 3 | `prod.yaml`, `admin-server.yaml` |

## Prod Image Overrides

Prod Applications set Helm parameters to use `petclinic-prod-*` ECR repository
names and the configured ECR registry. `api-gateway-prod` also disables ingress
in the current manifest.

## Apply

```bash
kubectl apply -f k8s/argocd/applications/project.yaml
kubectl apply -k k8s/argocd/applications/prod
```

After applying, sync from the Argo CD UI or CLI when ready.