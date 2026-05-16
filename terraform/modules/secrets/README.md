# Secrets Module

This module creates non-database Secrets Manager entries used by the platform
and applications.

## Resources

- Optional OpenAI API key secret.
- Grafana admin credential secret with a generated password.

## Secret Names

```text
<project_name>/<environment>/terraform/openai-api-key
<project_name>/<environment>/terraform/grafana-admin
```

With current defaults:

```text
petclinic/dev/terraform/openai-api-key
petclinic/dev/terraform/grafana-admin
```

## OpenAI Secret

When `create_openai_secret = true`, the module creates a secret version with:

```json
{
  "OPENAI_API_KEY": "<value>"
}
```

The secret version ignores later changes to `secret_string`, which helps avoid
accidental secret rotation through Terraform. The GitHub Actions workflows can
also create the Kubernetes `openai-secret` directly from the `OPENAI_API_KEY`
GitHub secret.

## Grafana Secret

The Grafana secret stores:

```json
{
  "username": "admin",
  "password": "<generated-password>"
}
```

## Inputs

- `project_name`
- `environment`
- `openai_api_key`
- `create_openai_secret`
- `tags`

## Outputs

- `openai_secret_arn`
- `openai_secret_name`
- `grafana_secret_arn`
- `grafana_secret_name`