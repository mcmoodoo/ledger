output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "bastion_eip" {
  value = aws_eip.bastion_eip.public_ip
}

output "bastion_eip_allocation_id" {
  value = aws_eip.bastion_eip.allocation_id
}

output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "bastion_instance_type" {
  value = aws_instance.bastion.instance_type
}

output "bastion_ami" {
  value = aws_instance.bastion.ami
}

output "bastion_availability_zone" {
  value = aws_instance.bastion.availability_zone
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}
