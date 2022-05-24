# Role for EC2 (Jenkins)
resource "aws_iam_role" "tdcs_role_jenkins" {
  name = "${local.project_id}-${local.env}-an2-role-jenkins"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "tdcs_role_jenkins" {
    name = "${local.project_id}-${local.env}-role-jenkins"
    role = aws_iam_role.tdcs_role_jenkins.name
}

resource "aws_iam_role_policy" "tdcs_stg_an2_iam_acm" {
  name = "${local.project_id}-${local.env}-iam-acm"
  role = aws_iam_role.tdcs_role_jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "acm:*"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:acm:ap-northeast-2:875054318754:certificate/*"
      },
    ]
  })
}