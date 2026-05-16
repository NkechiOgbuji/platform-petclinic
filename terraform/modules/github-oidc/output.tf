output "oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "IAM role ARN assumed by GitHub Actions."
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "IAM role name assumed by GitHub Actions."
  value       = aws_iam_role.github_actions.name
}

output "allowed_subjects" {
  description = "GitHub OIDC subjects allowed by the trust policy."
  value       = local.github_subjects
}