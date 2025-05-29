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
    cidr_blocks = ["172.58.164.214/32"]
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
  ami           = "ami-049b02d7bde2565cf"
  instance_type = "t2.small"
  subnet_id     = module.vpc.public_subnets[0]
  # associate_public_ip_address = true
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  user_data = file("cloud-init.yaml")
  # So I've got this bastion with aws setup. I need to set up the kubectl ahead of time?
  # How will I access the eks control plane node?
  # Let's configure git on the bastion to be able to pull the project from my github and apply the EKS tf. Oh and I need terraform on the bastion instance.
  # That means I will need to place a private key in my EC2 instance, is that secure? What are ways to do it?
  # so I created a granular access point with a deploy key scoped only for the ledger repo read-access-limited. I can now upload the private key to the bastion ec2

  root_block_device {
    volume_size = 15 # in GiB
    volume_type = "gp3"
  }

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_eip" "bastion_eip" {
  instance   = aws_instance.bastion.id
  depends_on = [aws_instance.bastion]
}

terraform {
  backend "s3" {
    bucket         = "mcmoodoo-terraform-state-bucket"
    key            = "bastion/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks" # optional but useful
  }
}
