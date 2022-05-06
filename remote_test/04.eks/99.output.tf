# eks cluster name
output "smp_cluster_name" {
    value = aws_eks_cluster.eks_api.name
}

output "smp_cluster_openid" {
    value = aws_iam_openid_connect_provider.eks_cluster_oidc.arn
}

