output "openai_secret_arn" {
  description = "OpenAI API key secret ARN"
  value       = try(aws_secretsmanager_secret.openai_api_key[0].arn, null)
}

output "openai_secret_name" {
  description = "OpenAI API key secret name"
  value       = try(aws_secretsmanager_secret.openai_api_key[0].name, null)
}

output "grafana_secret_arn" {
  description = "Grafana admin secret ARN"
  value       = aws_secretsmanager_secret.grafana_admin.arn
}

output "grafana_secret_name" {
  description = "Grafana admin secret name"
  value       = aws_secretsmanager_secret.grafana_admin.name
}