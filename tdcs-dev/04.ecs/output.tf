# ECS Instance Role
output "tdcs_role_ecs_instance" {
    value = aws_iam_role.tdcs_role_ecs_instance.arn
}