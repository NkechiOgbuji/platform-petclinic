variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "project_name" {
  description = "Project name used for IAM policy resource scopes."
  type        = string
  default     = "petclinic"
}

variable "environment" {
  description = "Environment name used for IAM policy resource scopes."
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version. Null lets AWS choose the default supported version."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets used by the EKS cluster and managed node group."
  type        = list(string)
}

variable "cluster_security_group_ids" {
  description = "Additional security groups attached to the EKS control plane."
  type        = list(string)
  default     = []
}

variable "endpoint_public_access" {
  description = "Whether the EKS API endpoint is publicly reachable."
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Whether the EKS API endpoint is privately reachable."
  type        = bool
  default     = false
}

variable "enabled_cluster_log_types" {
  description = "EKS control-plane log types to enable."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_days" {
  description = "CloudWatch retention for EKS control-plane logs."
  type        = number
  default     = 30
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired worker node count."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum worker node count."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum worker node count."
  type        = number
  default     = 4
}

variable "node_disk_size" {
  description = "Worker node disk size in GiB."
  type        = number
  default     = 20
}

variable "github_actions_role_arn" {
  description = "Bootstrap-created GitHub Actions role ARN to grant EKS cluster admin access."
  type        = string
  default     = ""
}

variable "admin_role_arns" {
  description = "Additional IAM role ARNs to grant EKS cluster admin access."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to EKS resources."
  type        = map(string)
  default     = {}
}