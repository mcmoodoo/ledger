output "instance_id" {
  description = "Bastion instance ID"
  value       = aws_instance.bastion.id
}

output "instance_public_ip" {
  description = "Bastion instance public IP"
  value       = aws_instance.bastion.public_ip
}

output "instance_private_ip" {
  description = "Bastion instance private IP"
  value       = aws_instance.bastion.private_ip
}

output "elastic_ip" {
  description = "Elastic IP address (if created)"
  value       = var.create_eip ? aws_eip.bastion_eip[0].public_ip : null
}

output "key_pair_name" {
  description = "Key pair name"
  value       = aws_key_pair.bastion_key.key_name
}