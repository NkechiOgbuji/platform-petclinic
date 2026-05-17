# Prod Environment

This is the production platform root. It mirrors the dev module composition but
uses production-oriented defaults and the `petclinic/prod/terraform.tfstate`
remote state key.

## What It Manages

- VPC and networking.
- ECR repositories with a `petclinic-prod` repository prefix.
- EKS cluster and node group.
- RDS MySQL with production-safe deletion settings.
- Secrets Manager entries.
- DNS and ACM for production hostnames.
- Platform add-ons, Argo CD, and observability.

## Defaults

Key defaults from `variable.tf`:

- `environment = "prod"`
- `project_name = "petclinic"`
- `aws_region = "us-east-2"`
- `repository_prefix = "petclinic-prod"`
- `cluster_name = "petclinic-prod-eks"`
- `vpc_cidr = "10.1.0.0/16"`
- `app_subdomain = "petclinic-prod"`
- `argocd_subdomain = "argocd-prod"`
- `grafana_subdomain = "grafana-prod"`
- `prometheus_subdomain = "prometheus-prod"`
- EKS desired node count is `3`, with min `3` and max `6`.
- RDS uses `db.t3.small`, 50 GB gp3 storage, Multi-AZ enabled, and 14 days of
  backup retention.
- `create_openai_secret = false` by default, so OpenAI runtime credentials
  should come from GitHub secrets or another controlled secret source unless you
  intentionally opt into Terraform-managed secret creation.

The RDS module enables final snapshots and deletion protection for non-dev
environments.

## Required Review Before Apply

- Review node group sizing, RDS class, Multi-AZ, backup retention, and storage.
- Confirm the Route 53 domain and hostnames.
- Confirm GitHub Actions role access and production environment protections.
- Confirm prod Argo CD sync policy. The current prod Applications are manual
  sync rather than automated.
- Confirm production ingress overrides. Some shared service values contain dev
  public hostnames for convenience, so prod Applications should override or
  disable those ingresses before public exposure.
- Confirm whether production should use Terraform-managed OpenAI Secrets Manager
  storage or workflow-created Kubernetes secrets.

## Usage

Create `terraform/environments/prod/terraform.tfvars` for production overrides
when needed. `terraform.tfvars` is no longer ignored by Git, so commit only
sanitized values and keep credentials out of the file.

```bash
terraform -chdir=terraform/environments/prod init
terraform -chdir=terraform/environments/prod fmt -check -recursive
terraform -chdir=terraform/environments/prod validate -no-color
terraform -chdir=terraform/environments/prod plan -var-file=terraform.tfvars
terraform -chdir=terraform/environments/prod apply -var-file=terraform.tfvars
```

## Important Outputs

- `kubectl_update_kubeconfig_command`
- `eks_cluster_name`
- `ecr_registry_url`
- `ecr_repository_urls`
- `rds_endpoint`
- `rds_secret_name`
- `application_namespace`
- `app_domain_name`
- `argocd_domain_name`
- `grafana_domain_name`
- `prometheus_domain_name`

## Post-Apply Checks

```bash
kubectl get nodes
kubectl get pods -n argocd
kubectl get pods -n external-secrets
kubectl get pods -n monitoring
kubectl get clustersecretstore aws-secrets-manager
```

When DNS ingress is enabled, the Terraform platform hostnames default to:

```text
https://petclinic-prod.phoniex.site
https://argocd-prod.phoniex.site
https://grafana-prod.phoniex.site
https://prometheus-prod.phoniex.site
```