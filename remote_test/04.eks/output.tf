# eks cluster name
output "smp_cluster_name" {
    value = aws_eks_cluster.eks_api.name
}



