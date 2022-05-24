# Role for EC2 (Jenkins)
resource "aws_iam_role" "tdcs_role_ecs_instance" {
  name = "${local.project_id}-${local.env}-role-ecs-instance"

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

resource "aws_iam_role_policy_attachment" "tdcs_role_ecs_instance" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.tdcs_role_ecs_instance.id
}

resource "aws_iam_instance_profile" "tdcs_role_ecs_instance" {
    name = "${local.project_id}-${local.env}-role-ecs-instance"
    role = aws_iam_role.tdcs_role_ecs_instance.name
}