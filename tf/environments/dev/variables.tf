variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
  default     = "dev"
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH to bastion"
  type        = list(string)
  default     = ["172.58.164.214/32"]
}

variable "bastion_ami_id" {
  description = "AMI ID for the bastion instance"
  type        = string
  default     = "ami-049b02d7bde2565cf"
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion"
  type        = string
  default     = "t2.small"
}

variable "user_data_file" {
  description = "Path to user data file"
  type        = string
  default     = "cloud-init.yaml"
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  default     = "mcmoodoo-terraform-state-bucket"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "dev-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.33"
}

variable "cluster_endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public endpoint"
  type        = list(string)
  default     = ["140.228.15.26/32", "50.17.239.156/32"]
}

variable "eks_managed_node_groups" {
  description = "EKS managed node groups configuration"
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
  }))
  default = {
    default = {
      instance_types = ["t3.small"]
      min_size       = 2
      max_size       = 2
      desired_size   = 2
    }
  }
}

variable "enable_irsa" {
  description = "Enable IAM roles for service accounts"
  type        = bool
  default     = true
}