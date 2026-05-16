variable "name_prefix" {
  description = "Name prefix for IAM resources."
  type        = string
}

variable "github_repositories" {
  description = "GitHub repositories allowed to assume the deployment role."
  type = list(object({
    owner        = string
    name         = string
    branches     = optional(list(string), ["main"])
    environments = optional(list(string), [])
  }))

  validation {
    condition     = length(var.github_repositories) > 0
    error_message = "At least one GitHub repository must be allowed."
  }
}

variable "repository_prefix" {
  description = "Plain ECR repository prefix, for example petclinic-dev. Do not include a trailing hyphen."
  type        = string
}

variable "role_name" {
  description = "Optional explicit IAM role name for GitHub Actions."
  type        = string
  default     = null
}

variable "additional_policy_arns" {
  description = "Additional managed policy ARNs to attach to the GitHub Actions role."
  type        = list(string)
  default     = []
}

variable "terraform_state_bucket_name" {
  description = "Optional S3 bucket name that stores Terraform remote state for workflows assuming this role."
  type        = string
  default     = ""
}

variable "terraform_state_key_prefix" {
  description = "Optional S3 key prefix containing Terraform remote state objects."
  type        = string
  default     = ""
}

variable "terraform_state_key_prefixes" {
  description = "Additional S3 key prefixes containing Terraform remote state objects."
  type        = list(string)
  default     = []
}

variable "terraform_state_kms_key_arn" {
  description = "Optional KMS key ARN used to encrypt the Terraform remote state bucket."
  type        = string
  default     = ""
}

variable "enable_platform_terraform_permissions" {
  description = "Whether to attach permissions for this role to plan and apply the platform Terraform stack."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to IAM resources."
  type        = map(string)
  default     = {}
}