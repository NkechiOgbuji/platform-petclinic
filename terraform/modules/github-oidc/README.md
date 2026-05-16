# GitHub OIDC Module

This module creates the AWS IAM resources that let GitHub Actions authenticate
to AWS without long-lived access keys.

## Resources

- GitHub OIDC provider for `https://token.actions.githubusercontent.com`.
- IAM role assumed by GitHub Actions through `sts:AssumeRoleWithWebIdentity`.
- ECR push and pull policy scoped to repositories matching
  `<repository_prefix>-*`.
- Optional Terraform state access policy scoped to configured S3 prefixes.
- Optional platform Terraform permissions for managing AWS platform services.
- Optional additional managed policy attachments.

## Trust Policy

Allowed GitHub subjects are generated from `github_repositories`.

Branch subjects look like:

```text
repo:<owner>/<repo>:ref:refs/heads/<branch>
```

Environment subjects look like:

```text
repo:<owner>/<repo>:environment:<environment>
```

## Inputs

Key inputs:

- `name_prefix`
- `github_repositories`
- `repository_prefix`
- `role_name`
- `additional_policy_arns`
- `terraform_state_bucket_name`
- `terraform_state_key_prefix`
- `terraform_state_key_prefixes`
- `terraform_state_kms_key_arn`
- `enable_platform_terraform_permissions`
- `tags`

## Outputs

- `oidc_provider_arn`
- `github_actions_role_arn`
- `github_actions_role_name`
- `allowed_subjects`

## Safety Notes

The OIDC provider, GitHub Actions role, and core policies use
`prevent_destroy`. Treat this as durable bootstrap infrastructure. Accidental
replacement can break all workflows that assume the role.