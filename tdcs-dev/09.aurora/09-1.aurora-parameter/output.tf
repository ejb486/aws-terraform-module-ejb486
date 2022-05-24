# Aurora Cluster Parameter 
output "tdcs_aurora_cluster_param" {
    value = aws_rds_cluster_parameter_group.tdcs_aurora_param.id
}

# Aurora Instance Parameter 
output "tdcs_aurora_instance_param" {
    value = aws_db_parameter_group.tdcs_aurora_param.id
}