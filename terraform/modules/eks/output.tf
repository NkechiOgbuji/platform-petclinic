output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint."
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded EKS cluster CA data."
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Primary EKS cluster security group ID."
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID used by EKS-managed nodes."
  value       = data.aws_security_group.nodes.id
}

output "oidc_provider_arn" {
  description = "EKS cluster OIDC provider ARN for IRSA."
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "EKS OIDC provider URL without the https:// prefix."
  value       = local.oidc_provider_url
}

output "node_role_arn" {
  description = "Managed node group IAM role ARN."
  value       = aws_iam_role.eks_nodes.arn
}

output "external_secrets_role_arn" {
  description = "IRSA role ARN used by External Secrets Operator."
  value       = aws_iam_role.external_secrets.arn
}

output "lb_controller_role_arn" {
  description = "IRSA role ARN used by AWS Load Balancer Controller."
  value       = aws_iam_role.lb_controller.arn
}