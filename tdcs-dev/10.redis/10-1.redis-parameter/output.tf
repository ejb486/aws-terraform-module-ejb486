# Redis Parameter
output "tdcs_redis_parameter" {
    value = aws_elasticache_parameter_group.tdcs_redis_param.name
}

# Redis User Group
output "tdcs_redis_usergroup" {
    value = aws_elasticache_user_group.tdcs_redis_usergroup.id
}

# Redis User
output "tdcs_redis_user" {
    value = aws_elasticache_user.tdcs_redis_user.arn
}