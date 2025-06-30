provider "aws" {
  region = var.region
}

module "networking" {
  source = "../../modules/networking"

  name                 = var.environment_name
  availability_zones   = ["${var.region}a", "${var.region}b"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  allowed_ssh_cidrs    = var.allowed_ssh_cidrs

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "iam" {
  source = "../../modules/iam"

  name = "${var.environment_name}-bastion"
  
  custom_policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "eks:*",
        "ec2:*",
        "iam:PassRole",
        "iam:GetRole",
        "iam:CreateRole",
        "iam:GetPolicy",
        "iam:CreatePolicy",
        "iam:AttachRolePolicy",
        "iam:PutRolePolicy",
        "iam:GetPolicyVersion",
        "iam:CreateInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:ListPolicyVersions",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "autoscaling:*",
        "cloudformation:*",
        "logs:*",
        "kms:TagResource",
        "kms:CreateKey",
        "kms:CreateAlias",
        "kms:ListAliases",
        "kms:DeleteAlias",
        "iam:DeletePolicy",
        "iam:ListInstanceProfilesForRole",
        "iam:CreateOpenIDConnectProvider",
        "iam:DeleteRole",
        "iam:TagOpenIDConnectProvider",
        "iam:GetOpenIDConnectProvider",
        "iam:DeleteOpenIDConnectProvider"
      ]
      Resource = "*"
    },
    {
      Effect   = "Allow"
      Action   = ["s3:ListBucket"]
      Resource = "arn:aws:s3:::${var.terraform_state_bucket}"
    },
    {
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "arn:aws:s3:::${var.terraform_state_bucket}/bastion/*"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "compute" {
  source = "../../modules/compute"

  name                         = "${var.environment_name}-bastion"
  ami_id                      = var.bastion_ami_id
  instance_type               = var.bastion_instance_type
  subnet_id                   = module.networking.public_subnets[0]
  security_group_id           = module.networking.bastion_security_group_id
  iam_instance_profile_name   = module.iam.instance_profile_name
  user_data                   = var.user_data_file

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

terraform {
  backend "s3" {
    bucket         = "mcmoodoo-terraform-state-bucket"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}