resource "aws_batch_compute_environment" "tdcs_batch" {
  compute_environment_name = "${local.project_id}-${local.env}-an2-batch"

  compute_resources {
    instance_role = aws_iam_instance_profile.tdcs_role_batch_instance.arn
    instance_type = ["c5.2xlarge"]

    max_vcpus = 16
    min_vcpus = 0
    security_group_ids = [data.terraform_remote_state.sg.outputs.tdcs_sg_batch]

    subnets = [
    data.terraform_remote_state.vpc.outputs.tdcs_dup_backend_subnet_ids[0], data.terraform_remote_state.vpc.outputs.tdcs_dup_backend_subnet_ids[1]
    ]

    type = "EC2"
  }

  service_role = aws_iam_role.tdcs_role_batch_service.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.tdcs_role_batch_service]
}