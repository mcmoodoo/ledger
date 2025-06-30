module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnets

  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  eks_managed_node_groups = var.eks_managed_node_groups

  enable_irsa = var.enable_irsa

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}