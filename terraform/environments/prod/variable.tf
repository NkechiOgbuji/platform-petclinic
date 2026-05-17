variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project identifier used for naming."
  type        = string
  default     = "petclinic"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-2"
}

variable "repository_prefix" {
  description = "Plain ECR repository prefix. Use petclinic-prod, not petclinic-prod-."
  type        = string
  default     = "petclinic-prod"
}

variable "github_actions_role_name" {
  description = "Bootstrap-owned IAM role name assumed by GitHub Actions."
  type        = string
  default     = "petclinic-github-actions-role"
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones."
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

variable "cluster_version" {
  description = "EKS Kubernetes version. Null lets AWS choose the default supported version."
  type        = string
  default     = null
}

variable "eks_endpoint_public_access" {
  description = "Whether the EKS API endpoint is publicly reachable."
  type        = bool
  default     = true
}

variable "eks_endpoint_private_access" {
  description = "Whether the EKS API endpoint is privately reachable."
  type        = bool
  default     = false
}

variable "eks_node_instance_types" {
  description = "EKS managed node group instance types."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Desired EKS worker node count."
  type        = number
  default     = 3
}

variable "eks_node_min_size" {
  description = "Minimum EKS worker node count."
  type        = number
  default     = 3
}

variable "eks_node_max_size" {
  description = "Maximum EKS worker node count."
  type        = number
  default     = 6
}

variable "github_actions_role_arn" {
  description = "GitHub Actions deployment role ARN output by terraform/bootstrap. This exact ARN is granted EKS cluster admin access."
  type        = string
  default     = ""
}

variable "eks_admin_role_arns" {
  description = "Additional IAM roles to grant EKS cluster admin access."
  type        = list(string)
  default     = []
}

variable "db_name" {
  description = "Database name."
  type        = string
  default     = "petclinic"
}

variable "db_username" {
  description = "Database master username."
  type        = string
  default     = "petclinic_admin"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.small"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB."
  type        = number
  default     = 50
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention in days."
  type        = number
  default     = 14
}

variable "openai_api_key" {
  description = "OpenAI API key stored in Secrets Manager when create_openai_secret is true."
  type        = string
  sensitive   = true
  default     = ""
}

variable "create_openai_secret" {
  description = "Whether to keep managing the OpenAI API key secret."
  type        = bool
  default     = false
}

variable "enable_dns_ingress" {
  description = "Whether to manage the Route 53 and ACM DNS ingress resources."
  type        = bool
  default     = true
}

variable "root_domain_name" {
  description = "Root domain name hosted in Route 53."
  type        = string
  default     = "phoniex.site"
}

variable "app_subdomain" {
  description = "Application subdomain under the root domain."
  type        = string
  default     = "petclinic-prod"
}

variable "argocd_subdomain" {
  description = "Argo CD UI subdomain under the root domain."
  type        = string
  default     = "argocd-prod"
}

variable "grafana_subdomain" {
  description = "Grafana UI subdomain under the root domain."
  type        = string
  default     = "grafana-prod"
}

variable "prometheus_subdomain" {
  description = "Prometheus UI subdomain under the root domain."
  type        = string
  default     = "prometheus-prod"
}

variable "grafana_service_type" {
  description = "Grafana Kubernetes service type for kube-prometheus-stack."
  type        = string
  default     = "ClusterIP"
}

variable "argocd_repo_url" {
  description = "Repository URL used by Argo CD. Keep this as this infra repo unless you move the chart."
  type        = string
  default     = "https://github.com/Goodnessoj/petclinic-Infra.git"
}

variable "argocd_repo_username" {
  description = "Username for optional Argo CD private repo credentials."
  type        = string
  default     = "x-access-token"
}

variable "argocd_repo_token" {
  description = "Optional Argo CD private repo token. Leave empty for public repos."
  type        = string
  sensitive   = true
  default     = ""
}