# Jenkins용 EC2
resource "aws_instance" "tdcs_ec2_ops" {
  instance_type          = "t3.medium"
  subnet_id              = data.terraform_remote_state.vpc.outputs.tdcs_unique_backend_subnet_ids[0]
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.tdcs_sg_ec2_jenkins, data.terraform_remote_state.sg.outputs.tdcs_sg_ec2_chmax, data.terraform_remote_state.sg.outputs.tdcs_sg_doss, data.terraform_remote_state.sg.outputs.tdcs_sg_hips]

  associate_public_ip_address = false
  ami = "ami-0609301e4f2d71ec9"

  instance_initiated_shutdown_behavior = "stop"
  disable_api_termination = true
  monitoring = false

  ebs_optimized       = true
  iam_instance_profile = aws_iam_instance_profile.tdcs_role_jenkins.id

root_block_device {
	encrypted           = true
	volume_size         = 30
	volume_type         = "gp2"
	tags                = { 
		"Name" 	        = "${local.project_id}-${local.env}-ebs-jenkins-root",
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
		}
}

  tags = {
      "Name"  = "${local.project_id}-${local.env}-an2-ec2-jenkins"
      "environment" = "${local.env}",
      "personalinformation" = "no", 
      "servicetitle" = "${local.project_id}",
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
    }
}

# IF용 EC2 (private용)
resource "aws_instance" "tdcs_ec2_if_private" {
  instance_type          = "t3.medium"
  subnet_id              = data.terraform_remote_state.vpc.outputs.tdcs_unique_backend_subnet_ids[0]
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.tdcs_sg_ec2_if, data.terraform_remote_state.sg.outputs.tdcs_sg_ec2_chmax, data.terraform_remote_state.sg.outputs.tdcs_sg_hips]

  associate_public_ip_address = false
  ami = "ami-0609301e4f2d71ec9"

  instance_initiated_shutdown_behavior = "stop"
  disable_api_termination = true
  monitoring = false

  ebs_optimized       = true

root_block_device {
	encrypted           = true
	volume_size         = 30
	volume_type         = "gp2"
	tags                = { 
		  "Name" 	          = "${local.project_id}-${local.env}-ebs-eai-root",
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
		}
  }

  tags = {
      "Name"  = "${local.project_id}-${local.env}-an2-ec2-eai",
      "environment" = "${local.env}",
      "personalinformation" = "no", 
      "servicetitle" = "${local.project_id}",
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
    } 
}

# Bastion용 EC2
resource "aws_instance" "tdcs_ec2_bst" {
  instance_type          = "t2.medium"
  subnet_id              = data.terraform_remote_state.vpc.outputs.tdcs_unique_backend_subnet_ids[1]
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.tdcs_sg_ec2_bst, data.terraform_remote_state.sg.outputs.tdcs_sg_ec2_chmax, data.terraform_remote_state.sg.outputs.tdcs_sg_hips]

  associate_public_ip_address = false
  ami = "ami-0609301e4f2d71ec9"

  instance_initiated_shutdown_behavior = "stop"
  disable_api_termination = true
  monitoring = false

root_block_device {
	encrypted           = true
	volume_size         = 30
	volume_type         = "gp2"
	tags                = { 
		"Name" 	        = "${local.project_id}-${local.env}-ebs-bst-root",
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
		}
}

  tags = {
      "Name"  = "${local.project_id}-${local.env}-an2-ec2-bst"
      "environment" = "${local.env}",
      "personalinformation" = "no", 
      "servicetitle" = "${local.project_id}",
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
    }
}