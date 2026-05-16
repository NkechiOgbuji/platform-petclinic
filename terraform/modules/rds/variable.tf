variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for DB subnet group"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for DB placement"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "EKS cluster security group ID (allows MySQL access)"
  type        = string
}

variable "eks_node_security_group_id" {
  description = "EKS worker node security group ID"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "petclinic"
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "petclinic_admin"
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention in days"
  type        = number
  default     = 7
}