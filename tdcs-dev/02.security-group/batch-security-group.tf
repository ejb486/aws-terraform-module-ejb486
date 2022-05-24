# ECS EC2용 security group
resource "aws_security_group" "tdcs_sg_batch_insance" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.tdcs_vpc_id
  name = "${local.project_id}-${local.env}-an2-sgroup-batch-instance"
  description = "${local.project_id}-${local.env}-an2-sgroup-batch-instance"

  tags = {
	  Name = "${local.project_id}-${local.env}-an2-sgroup-batch-instance"
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
    }
}

resource "aws_security_group_rule" "tdcs_sgr_batch_egress" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.tdcs_sg_batch_insance.id
}