provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.region
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["209.162.61.154/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_instance" "bastion" {
  ami           = "ami-0698f542789a8d344"
  instance_type = "t2.small"
  subnet_id     = module.vpc.public_subnets[0]
  # associate_public_ip_address = true
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update && apt upgrade -y

              # set vim bindings echo "set -o vi" >> ~/.bashrc
              echo "set -o vi" >> $HOME/.bashrc
              . $HOME/.bashrc

              # Make cargo available system-wide (optional)
              # echo 'source $HOME/.cargo/env' >> /etc/profile
              EOF

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
}
