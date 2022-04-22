# eks cluster role arn 
output "smp_cluster_security_group_id" {
    value = aws_security_group.sg_cluster.id
}

# eks node group role arn 
output "smp_node_security_group_id" {
    value = aws_security_group.sg_allnodes.id
}
