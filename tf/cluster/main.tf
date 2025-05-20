provider "aws" {
  region = var.region
}

# 🔗 Pull VPC info from the Bastion project's remote state
data "terraform_remote_state" "bastion" {
  backend = "s3"
  config = {
    bucket = "mcmoodoo-terraform-state-bucket"
    key    = "bastion/terraform.tfstate"
    region = "us-east-1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"
  
  vpc_id     = data.terraform_remote_state.bastion.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.bastion.outputs.private_subnets

  cluster_endpoint_private_access        = true
  cluster_endpoint_public_access         = true
  cluster_endpoint_public_access_cidrs   = ["140.228.15.26/32", "50.17.239.156/32"]

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]
      min_size       = 2
      max_size       = 2
      desired_size   = 2
    }
  }

  enable_irsa = true
}
