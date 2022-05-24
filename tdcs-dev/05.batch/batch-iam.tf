# Role for Batch Instance
resource "aws_iam_role" "tdcs_role_batch_instance" {
  name = "${local.project_id}-${local.env}-role-batch-instance"

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

resource "aws_iam_role_policy_attachment" "tdcs_role_batch_instance" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.tdcs_role_batch_instance.id
}

resource "aws_iam_instance_profile" "tdcs_role_batch_instance" {
    name = "${local.project_id}-${local.env}-role-batch-instance"
    role = aws_iam_role.tdcs_role_batch_instance.name
}

# Role for Batch Service
resource "aws_iam_role" "tdcs_role_batch_service" {
  name = "${local.project_id}-${local.env}-role-batch-service"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "batch.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "tdcs_role_batch_service" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
  role       = aws_iam_role.tdcs_role_batch_service.name
}

resource "aws_iam_instance_profile" "tdcs_role_batch_service" {
  name = "${local.project_id}-${local.env}-role-batch-sercvice"
  role = aws_iam_role.tdcs_role_batch_service.name
}