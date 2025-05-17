output "cluster_name" {
  value = module.eks.cluster_name
}

output "kubeconfig_command" {
  value = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}"
}
