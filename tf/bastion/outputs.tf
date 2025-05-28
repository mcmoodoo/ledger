output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "bastion_eip" {
  value = aws_eip.bastion_eip.public_ip
}
