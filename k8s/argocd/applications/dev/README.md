# Dev Argo CD Applications

This folder contains the dev Argo CD Applications for Petclinic.

## Behavior

All dev Applications:

- Deploy to namespace `petclinic-dev`.
- Use project `petclinic`.
- Source charts from `helm/petclinic-service`.
- Track `targetRevision: main`.
- Merge `helm-values/dev.yaml` first and the service values file second.
- Enable automated sync with prune and self-heal.
- Use sync options:
  - `CreateNamespace=true`
  - `ApplyOutOfSyncOnly=true`
  - `PruneLast=true`

## Applications

| Application | Release | Sync wave | Values |
| --- | --- | ---: | --- |
| `config-server-dev` | `config-server` | 0 | `dev.yaml`, `config-server.yaml` |
| `discovery-server-dev` | `discovery-server` | 1 | `dev.yaml`, `discovery-server.yaml` |
| `customers-service-dev` | `customers-service` | 2 | `dev.yaml`, `customers-service.yaml` |
| `vets-service-dev` | `vets-service` | 2 | `dev.yaml`, `vets-service.yaml` |
| `visits-service-dev` | `visits-service` | 2 | `dev.yaml`, `visits-service.yaml` |
| `genai-service-dev` | `genai-service` | 2 | `dev.yaml`, `genai-service.yaml` |
| `api-gateway-dev` | `api-gateway` | 3 | `dev.yaml`, `api-gateway.yaml` |
| `admin-server-dev` | `admin-server` | 3 | `dev.yaml`, `admin-server.yaml` |

## Apply

```bash
kubectl apply -f k8s/argocd/applications/project.yaml
kubectl apply -k k8s/argocd/applications/dev
```

## Inspect

```bash
kubectl get applications -n argocd -o wide
kubectl get pods,svc,ingress -n petclinic-dev
```