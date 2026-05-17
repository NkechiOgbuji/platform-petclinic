output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "VPC security group attached to the EKS control plane."
  value       = module.vpc.eks_cluster_security_group_id
}

output "eks_cluster_admin_principal" {
  description = "GitHub Actions principal intended for cluster administration."
  value       = local.github_actions_role_arn
}

output "kubectl_update_kubeconfig_command" {
  description = "Command for updating local kubeconfig."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "ecr_registry_url" {
  description = "ECR registry URL without a repository name."
  value       = module.ecr.registry_url
}

output "ecr_repository_urls" {
  description = "Map of service names to ECR repository URLs."
  value       = module.ecr.repository_urls
}

output "ecr_repository_names" {
  description = "List of ECR repository names."
  value       = module.ecr.repository_names
}

output "rds_endpoint" {
  description = "RDS instance endpoint."
  value       = module.rds.db_endpoint
}

output "rds_secret_arn" {
  description = "Secrets Manager secret ARN for database credentials."
  value       = module.rds.db_secret_arn
}

output "rds_secret_name" {
  description = "Secrets Manager secret name consumed by the Helm chart ExternalSecret."
  value       = module.rds.db_secret_name
}

output "grafana_secret_arn" {
  description = "Grafana admin secret ARN."
  value       = module.secrets.grafana_secret_arn
}

output "openai_secret_arn" {
  description = "OpenAI API key secret ARN."
  value       = module.secrets.openai_secret_arn
}

output "github_actions_role_arn" {
  description = "IAM role ARN assumed by GitHub Actions."
  value       = local.github_actions_role_arn
}

output "external_secrets_role_arn" {
  description = "External Secrets Operator IRSA role ARN."
  value       = module.addons.external_secrets_role_arn
}

output "lb_controller_role_arn" {
  description = "AWS Load Balancer Controller IRSA role ARN."
  value       = module.eks.lb_controller_role_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "AWS Load Balancer Controller IRSA role ARN."
  value       = module.addons.aws_load_balancer_controller_role_arn
}

output "external_dns_role_arn" {
  description = "ExternalDNS IRSA role ARN."
  value       = module.addons.external_dns_role_arn
}

output "application_namespace" {
  description = "Kubernetes namespace created for the Petclinic application."
  value       = module.addons.application_namespace
}

output "microservices_security_group_id" {
  description = "Application load balancer / microservices security group ID."
  value       = module.vpc.microservices_security_group_id
}

output "route53_zone_id" {
  description = "Route 53 hosted zone ID."
  value       = try(module.dns_ingress[0].route53_zone_id, null)
}

output "root_domain_name" {
  description = "Root domain name."
  value       = try(module.dns_ingress[0].root_domain_name, null)
}

output "app_domain_name" {
  description = "Full application domain name."
  value       = try(module.dns_ingress[0].app_domain_name, null)
}

output "argocd_domain_name" {
  description = "Argo CD UI domain name."
  value       = var.enable_dns_ingress ? local.argocd_domain_name : null
}

output "grafana_domain_name" {
  description = "Grafana UI domain name."
  value       = var.enable_dns_ingress ? local.grafana_domain_name : null
}

output "prometheus_domain_name" {
  description = "Prometheus UI domain name."
  value       = var.enable_dns_ingress ? local.prometheus_domain_name : null
}

output "acm_certificate_arn" {
  description = "Validated ACM certificate ARN."
  value       = try(module.dns_ingress[0].acm_certificate_arn, null)
}

output "acm_certificate_validation_id" {
  description = "ACM certificate validation ID."
  value       = try(module.dns_ingress[0].acm_certificate_validation_id, null)
}

output "hosted_zone_name_servers" {
  description = "Route 53 hosted zone name servers."
  value       = try(module.dns_ingress[0].hosted_zone_name_servers, [])
}