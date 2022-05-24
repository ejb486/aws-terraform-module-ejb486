# rds security group
resource "aws_security_group" "sg_rds" {
  name = "sgroup-rds-tdcs-prd"
  description = "sgroup-rds-tdcs-prd"
  vpc_id      = aws_vpc.tdcs_vpc.id
  tags = merge(local.global_tags, {
    "Name"    = "sgroup-rds-tdcs-prd",
    "Creator" = "1112965"
  })
}

resource "aws_security_group_rule" "sgr_rds_egress" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg_rds.id
}

resource "aws_security_group_rule" "sgr_rds_ingress_ch" {
  type              = "ingress"
  cidr_blocks       = ["100.64.32.197/32", "100.64.32.218/32"]
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP"
  security_group_id = aws_security_group.sg_rds.id
  description       = "Chakramax G/W"
}

resource "aws_security_group_rule" "sgr_rds_ingress_xlog" {
  type              = "ingress"
  cidr_blocks       = ["100.64.41.14/32"]
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP"
  security_group_id = aws_security_group.sg_rds.id
  description       = "XLOG EC2"
}

/*
resource "aws_security_group_rule" "sgr_rds_ingress_db" {
  type              = "ingress"
  cidr_blocks       = ["10.40.10.158/32", "172.31.38.157/32", "150.19.42.172/32"]
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP"
  security_group_id = aws_security_group.sg_rds.id
  description       = "AS-IS Database"
}

resource "aws_security_group_rule" "sgr_rds_ingress_nlb" {
  type              = "ingress"
  cidr_blocks       = ["100.64.41.28/32", "100.64.41.9/32"]
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP"
  security_group_id = aws_security_group.sg_rds.id
  description       = "NLB"
}

# rds security group
resource "aws_security_group" "sg_nlb_rds" {
  name = "sgroup-nlb-rds-tdcs-prd"
  description = "sgroup-nlb-rds-tdcs-prd"
  vpc_id      = aws_vpc.tdcs_vpc.id
  tags = merge(local.global_tags, {
    "Name"    = "sgroup-nlb-rds-tdcs-prd",
    "Creator" = "1112965"
  })
}
*/