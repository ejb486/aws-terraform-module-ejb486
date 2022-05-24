# Role for EC2 (Jenkins)
resource "aws_iam_role" "tdcs_role_backup" {
  name = "${local.project_id}-${local.env}-an2-role-backup"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "tdcs_role_backup_1" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.tdcs_role_backup.id
}

resource "aws_iam_role_policy_attachment" "tdcs_role_backup_2" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.tdcs_role_backup.id
}