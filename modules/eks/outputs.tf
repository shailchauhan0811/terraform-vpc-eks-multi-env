output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_certificate_authority" {
  description = "EKS cluster CA certificate"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "node_group_name" {
  description = "EKS node group name"
  value       = aws_eks_node_group.node_group.node_group_name
}
