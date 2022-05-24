# AuroraDB Monitoring Role
resource "aws_iam_role" "rds_monitoring_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = [
              "monitoring.rds.amazonaws.com"
            ]
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  name                  = "rds-monitoring-role"
  path                  = "/"
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.rds_monitoring_role.id
}