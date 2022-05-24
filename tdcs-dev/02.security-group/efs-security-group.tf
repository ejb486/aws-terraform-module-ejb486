# EFS용 security group
resource "aws_security_group" "tdcs_sg_efs" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.tdcs_vpc_id
  name        = "${local.project_id}-${local.env}-an2-sgroup-efs"
  description = "${local.project_id}-${local.env}-an2-sgroup-efs"
	
  tags = {
	Name = "${local.project_id}-${local.env}-an2-sgroup-efs" 
    }
}

resource "aws_security_group_rule" "tdcs_sgr_efs_egress" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.tdcs_sg_efs.id
}


resource "aws_security_group_rule" "tdcs_efs_ingress_1" {
  type              = "ingress"
  cidr_blocks       = ["100.64.0.0/24", "100.64.1.0/24"]
  from_port         = 2049
  to_port           = 2049
  protocol          = "TCP"
  security_group_id = aws_security_group.tdcs_sg_efs.id
  description       = "Subnet Dup Backend A/C"
}