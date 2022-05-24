# Redis용 security group
resource "aws_security_group" "tdcs_sg_aurora" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.tdcs_vpc_id
  name        = "${local.project_id}-${local.env}-an2-sgroup-auroradb"
  description = "${local.project_id}-${local.env}-an2-sgroup-auroradb"
	
  tags = {
	Name = "${local.project_id}-${local.env}-an2-sgroup-auroradb"
  "sgowner" = "CA_rds_admin"
    }
}

resource "aws_security_group_rule" "tdcs_sgr_aurora_egress" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.tdcs_sg_aurora.id
}

resource "aws_security_group_rule" "tdcs_sgr_aurora_ingress_1" {
  type              = "ingress"
  cidr_blocks       = ["100.64.32.197/32", "100.64.32.218/32"]
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP"
  security_group_id = aws_security_group.tdcs_sg_aurora.id
  description       = "Chakramax G/W"
}

resource "aws_security_group_rule" "tdcs_aurora_ingress_2" {
  type              = "ingress"
  cidr_blocks       = ["100.64.41.24/32"]
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP"
  security_group_id = aws_security_group.tdcs_sg_aurora.id
  description       = "Bastion EC2"
}

resource "aws_security_group_rule" "tdcs_aurora_ingress_3" {
  type              = "ingress"
  cidr_blocks       = ["100.64.41.13/32"]
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP"
  security_group_id = aws_security_group.tdcs_sg_aurora.id
  description       = "DMS Instance"
}

resource "aws_security_group_rule" "tdcs_aurora_ingress_4" {
  type              = "ingress"
  cidr_blocks       = ["10.40.10.158/32", "172.31.38.157/32", "150.19.42.172/32"]
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP"
  security_group_id = aws_security_group.tdcs_sg_aurora.id
  description       = "ASIS DB"
}

resource "aws_security_group_rule" "tdcs_aurora_ingress_5" {
  type              = "ingress"
  cidr_blocks       = ["100.64.41.14/32"]
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP"
  security_group_id = aws_security_group.tdcs_sg_aurora.id
  description       = "XLOG EC2"
}