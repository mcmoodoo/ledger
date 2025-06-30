variable "name" {
  description = "Name prefix for networking resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT gateway for private subnets"
  type        = bool
  default     = true
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH to bastion"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}