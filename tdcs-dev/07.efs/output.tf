# EFS
output "tdcs_efs_applog_arn" {
    value = aws_efs_file_system.tdcs_efs_applog.arn
}