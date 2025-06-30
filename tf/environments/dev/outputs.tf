output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnets
}

output "bastion_instance_id" {
  description = "Bastion instance ID"
  value       = module.compute.instance_id
}

output "bastion_public_ip" {
  description = "Bastion public IP"
  value       = module.compute.elastic_ip
}

output "bastion_security_group_id" {
  description = "Bastion security group ID"
  value       = module.networking.bastion_security_group_id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}