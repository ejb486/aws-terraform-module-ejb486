# Jenkins EC2용 security group
resource "aws_security_group" "tdcs_sg_jenkins_ec2" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.tdcs_vpc_id
  name = "${local.project_id}-${local.env}-an2-sgroup-ec2-jenkins"
  description = "${local.project_id}-${local.env}-an2-sgroup-ec2-jenkins"

  tags = {
	  Name = "${local.project_id}-${local.env}-an2-sgroup-ec2-jenkins"
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
    }
}

# EAI EC2용 security group
resource "aws_security_group" "tdcs_sg_if_ec2" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.tdcs_vpc_id
  name = "${local.project_id}-${local.env}-an2-sgroup-ec2-eai"
  description = "${local.project_id}-${local.env}-an2-sgroup-ec2-eai"

  tags = {
	  Name = "${local.project_id}-${local.env}-an2-sgroup-ec2-eai"
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
    }
}

# Bastion EC2용 security group
resource "aws_security_group" "tdcs_sg_bst_ec2" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.tdcs_vpc_id
  name = "${local.project_id}-${local.env}-an2-sgroup-ec2-bst"
  description = "${local.project_id}-${local.env}-an2-sgroup-ec2-bst"

  tags = {
	  Name = "${local.project_id}-${local.env}-an2-sgroup-ec2-bst"
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
    }
}

# AMI용 security group
resource "aws_security_group" "tdcs_sg_ami" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.tdcs_vpc_id
  name = "${local.project_id}-${local.env}-an2-sgroup-ami"
  description = "${local.project_id}-${local.env}-an2-sgroup-ami"

  tags = {
	  Name = "${local.project_id}-${local.env}-an2-sgroup-ami"
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
    }
}


/*
resource "aws_security_group_rule" "smp_sgr_ami_egress" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.smp_sg_ami.id
}

resource "aws_security_group_rule" "smp_sgr_ami_ingress" {
  type              = "ingress"
  cidr_blocks       = ["100.64.32.142/32"]
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  security_group_id = aws_security_group.smp_sg_ami.id
  description       = ""
}

*/

# Chmax용 security group
resource "aws_security_group" "tdcs_sg_ec2_chmax" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.tdcs_vpc_id
  name = "${local.project_id}-${local.env}-an2-sgroup-chmax"
  description = "${local.project_id}-${local.env}-an2-sgroup-chmax"

  tags = {
	  Name = "${local.project_id}-${local.env}-an2-sgroup-chmax"
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
    }
}

resource "aws_security_group_rule" "tdcs_sgr_chmax_egress" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.tdcs_sg_ec2_chmax.id
}

resource "aws_security_group_rule" "tdcs_sgr_chmax_ingress" {
  type              = "ingress"
  cidr_blocks       = ["100.64.32.218/32", "100.64.32.197/32"]
  from_port         = 21
  to_port           = 22
  protocol          = "TCP"
  security_group_id = aws_security_group.tdcs_sg_ec2_chmax.id
  description       = "Chmax G/W"
}

# DOSS용 security group
resource "aws_security_group" "tdcs_sg_doss" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.tdcs_vpc_id
  name = "${local.project_id}-${local.env}-an2-sgroup-doss"
  description = "${local.project_id}-${local.env}-an2-sgroup-doss"
  tags = {
	  Name = "${local.project_id}-${local.env}-an2-sgroup-doss"
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
    }
}
/*
resource "aws_security_group_rule" "smp_sgr_doss_egress" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.smp_sg_doss.id
}

resource "aws_security_group_rule" "smp_sgr_doss_ingress_1" {
  type              = "ingress"
  cidr_blocks       = ["20.194.0.172/32", "100.64.69.21/32"]
  from_port         = 10170
  to_port           = 10170
  protocol          = "TCP"
  security_group_id = aws_security_group.smp_sg_doss.id
  description       = "doss-prd-tool-jks02"
}

resource "aws_security_group_rule" "smp_sgr_doss_ingress_2" {
  type              = "ingress"
  cidr_blocks       = ["20.194.0.172/32", "100.64.69.21/32"]
  from_port         = 10160
  to_port           = 10160
  protocol          = "TCP"
  security_group_id = aws_security_group.smp_sg_doss.id
  description       = "doss-prd-tool-jks02"
}

resource "aws_security_group_rule" "smp_sgr_doss_ingress_3" {
  type              = "ingress"
  cidr_blocks       = ["100.64.71.206/32", "52.231.66.208/32"]
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  security_group_id = aws_security_group.smp_sg_doss.id
  description       = "doss.sktelecom.com"
}

resource "aws_security_group_rule" "smp_sgr_doss_ingress_4" {
  type              = "ingress"
  cidr_blocks       = ["100.64.71.206/32", "52.231.66.208/32"]
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  security_group_id = aws_security_group.smp_sg_doss.id
  description       = "doss.sktelecom.com"
}

*/

# HIPS용 security group
resource "aws_security_group" "tdcs_sg_hips" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.tdcs_vpc_id
  name = "${local.project_id}-${local.env}-an2-sgroup-hips"
  description = "${local.project_id}-${local.env}-an2-sgroup-hips"

  tags = {
	  Name = "${local.project_id}-${local.env}-an2-sgroup-hips"
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
    }
}

resource "aws_security_group_rule" "tdcs_sgr_hips_egress" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.tdcs_sg_hips.id
}

resource "aws_security_group_rule" "tdcs_sgr_hips_ingress" {
  type              = "ingress"
  cidr_blocks       = ["100.64.32.133/32"]
  from_port         = 4112
  to_port           = 4118
  protocol          = "TCP"
  security_group_id = aws_security_group.tdcs_sg_hips.id
  description       = "HIPS"
}