variable "name" {
  description = "Name prefix for compute resources"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the bastion instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the bastion"
  type        = string
  default     = "t2.small"
}

variable "subnet_id" {
  description = "Subnet ID where the bastion will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the bastion"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for the bastion"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "user_data" {
  description = "Path to user data file"
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Size of root volume in GiB"
  type        = number
  default     = 18
}

variable "root_volume_type" {
  description = "Type of root volume"
  type        = string
  default     = "gp3"
}

variable "create_eip" {
  description = "Whether to create an Elastic IP"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}