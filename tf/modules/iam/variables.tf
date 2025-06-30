variable "name" {
  description = "Name prefix for IAM resources"
  type        = string
}

variable "custom_policy_statements" {
  description = "Custom IAM policy statements"
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = string
  }))
  default = []
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  default     = null
}

variable "terraform_state_key_prefix" {
  description = "S3 key prefix for Terraform state access"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}