variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name used for secret naming."
  type        = string
  default     = "petclinic"
}

variable "openai_api_key" {
  description = "OpenAI API key stored in Secrets Manager."
  type        = string
  sensitive   = true
  default     = ""
}

variable "create_openai_secret" {
  description = "Whether to manage the OpenAI API key secret."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to secrets."
  type        = map(string)
  default     = {}
}