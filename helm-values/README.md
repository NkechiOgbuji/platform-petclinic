# Helm Values

This folder contains values files used by the Helm charts and Argo CD
Applications.

## File Types

| File type | Examples | Purpose |
| --- | --- | --- |
| Environment values | `dev.yaml`, `prod.yaml` | Shared defaults for an environment. |
| Service values | `api-gateway.yaml`, `customers-service.yaml` | Service-specific image, ports, env vars, ingress, monitoring, and init container settings. |
| Secrets values | `secrets-dev.yaml`, `secrets-prod.yaml` | Remote AWS Secrets Manager names for the shared secrets chart. |

## Merge Order

Argo CD and Helm merge values in order. Later files win:

```yaml
valueFiles:
  - ../../helm-values/dev.yaml
  - ../../helm-values/customers-service.yaml
```

This means service files override environment defaults.

## Service Matrix

| Service | Values file | Service port | Target port | Notes |
| --- | --- | ---: | ---: | --- |
| `config-server` | `config-server.yaml` | 8888 | 8888 | Reads config from the Spring Petclinic config repository. |
| `discovery-server` | `discovery-server.yaml` | 8761 | 8761 | Eureka discovery service; dev exposes `eureka.phoniex.site` and `discovery.phoniex.site`. |
| `customers-service` | `customers-service.yaml` | 8081 | 8081 | Registers with Eureka and waits for config server. |
| `visits-service` | `visits-service.yaml` | 8082 | 8082 | Registers with Eureka and waits for config server. |
| `vets-service` | `vets-service.yaml` | 8083 | 8083 | Registers with Eureka and waits for config server. |
| `genai-service` | `genai-service.yaml` | 8084 | 8084 | Consumes `openai-secret`. |
| `api-gateway` | `api-gateway.yaml` | 80 | 8080 | Public edge service; dev exposes `petclinic.phoniex.site`. |
| `admin-server` | `admin-server.yaml` | 9090 | 9090 | Admin UI/service; dev exposes `petclinic.phoniex.site/admin`. |

The shared service values are used by both dev and prod Argo CD Applications.
Some files intentionally contain dev public ingress hosts for the current dev
deployment. Prod Applications should override or disable those ingress values
before exposing production traffic.

## Image Tag Updates

The `update-image-tags.yml` workflow updates service values files when the
application build pipeline sends a dispatch event. It rewrites:

- `image.tag`

The service chart requires `image.tag` plus either `image.repository` or
`image.repositoryPrefix`. Environment values provide the repository prefix, and
service values carry the mutable image tag.

## Environment Defaults

`dev.yaml` sets low resource requests and single replicas by default.

`prod.yaml` sets higher resources, two replicas, and stricter autoscaling and
PDB defaults. The prod Argo CD Applications can still override image registry
and repository parameters when they need explicit repository names.

## Secrets Values

`secrets-dev.yaml` points to:

```text
petclinic/dev/terraform/database
petclinic/dev/terraform/openai-api-key
```

`secrets-prod.yaml` points to:

```text
petclinic/prod/terraform/database
petclinic/prod/terraform/openai-api-key
```