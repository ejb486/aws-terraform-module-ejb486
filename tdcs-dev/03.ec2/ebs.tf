resource "aws_ebs_volume" "tdcs_ec2_ops_1" {
  availability_zone = "ap-northeast-2a"
  size              = 30
  encrypted   = true

  tags              = { 
	"Name" 	        = "${local.project_id}-${local.env}-ebs-jenkins-app",
    "creator"       = "P092913",
    "operator1"     = "P092913",
    "operator2"     = "P069329"
    }
}

resource "aws_volume_attachment" "tdcs_ec2_ops_1" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.tdcs_ec2_ops_1.id
  instance_id = aws_instance.tdcs_ec2_ops.id
}


resource "aws_ebs_volume" "tdcs_ec2_bst_1" {
  availability_zone = "ap-northeast-2c"
  size              = 30
  encrypted   = true

  tags              = { 
	"Name" 	        = "${local.project_id}-${local.env}-ebs-bst-app",
    "creator"       = "P092913",
    "operator1"     = "P092913",
    "operator2"     = "P069329"
    }
}

resource "aws_volume_attachment" "tdcs_ec2_bst_1" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.tdcs_ec2_bst_1.id
  instance_id = aws_instance.tdcs_ec2_bst.id
}

resource "aws_ebs_volume" "tdcs_ec2_eai_private_1" {
  availability_zone = "ap-northeast-2a"
  size              = 70
  encrypted   = true

  tags              = { 
	"Name" 	        = "${local.project_id}-${local.env}-ebs-eai-app",
    "creator"       = "P092913",
    "operator1"     = "P092913",
    "operator2"     = "P069329"
    }
}

resource "aws_volume_attachment" "tdcs_ec2_eai_private_1" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.tdcs_ec2_eai_private_1.id
  instance_id = aws_instance.tdcs_ec2_if_private.id
}

resource "aws_ebs_volume" "tdcs_ec2_bst_2" {
  availability_zone = "ap-northeast-2c"
  size              = 10
  encrypted   = true

  tags              = { 
	"Name" 	        = "${local.project_id}-${local.env}-ebs-bst-mysql",
    "creator"       = "P092913",
    "operator1"     = "P092913",
    "operator2"     = "P069329"
    }
}

resource "aws_volume_attachment" "tdcs_ec2_bst_2" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.tdcs_ec2_bst_2.id
  instance_id = aws_instance.tdcs_ec2_bst.id
}