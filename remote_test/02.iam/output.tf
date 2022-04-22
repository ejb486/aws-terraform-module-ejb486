# eks cluster role arn 
output "smp_cluster_role_arn" {
    value = aws_iam_role.eks_cluster_ServiceRole.arn
}

# eks node group role arn 
output "smp_node_group_role_arn" {
    value = aws_iam_role.eks_nodegroup_NodeInstanceRole.arn
}


