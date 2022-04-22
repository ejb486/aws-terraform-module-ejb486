################################################################################
################################################################################
#####                                                                      #####
#####   efs 관련 생성                                                       #####
#####                                                                      #####
################################################################################
################################################################################


################################################################################
#####   			    Security group 생성        							#####
################################################################################
resource "aws_security_group" "smp_efs" {
    vpc_id      = data.terraform_remote_state.vpc.smp_vpc_id  #aws_vpc.api_vpc.id
    name        = "${local.project_id}-${local.env}-an2-sgroup-efs-application"
    description = "Inbound EKS NODE for EFS"
	
    egress {
        cidr_blocks = [ "0.0.0.0/0" ]
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
    }

    tags = {
	    Name = "${local.project_id}-${local.env}-an2-sgroup-efs-application" 
    }
}


################################################################################
#####   						efs  생성    								#####
################################################################################

resource "aws_efs_file_system" "efs_application" {
    encrypted = true
    performance_mode = "generalPurpose"

#    kms_key_id = aws_kms_key.efs_key.arn

    tags = {
	    Name = "${local.project_id}-${local.env}-an2-efs-application"
    }
}

################################################################################
#####   				mount target  생성    								#####
################################################################################

resource "aws_efs_mount_target" "target" {
    count = length(local.aws_azs)
    file_system_id  = aws_efs_file_system.efs_application.id
    subnet_id       = element(data.terraform_remote_state.vpc.smp_unique_backend_subnet_ids, count.index)   #element(aws_subnet.api_private_unique_backend_subnet.*.id, count.index)
    security_groups = [ aws_security_group.smp_efs.id ]
}

#resource "aws_kms_key" "efs_key" {
#    description = "Default key that protects my EFS filesystems when no other key is defined"
#    enable_key_rotation = true
#
#    policy = "{\"Id\":\"auto-elasticfilesystem-1\",\"Statement\":[{\"Action\":[\"kms:Encrypt\",\"kms:Decrypt\",\"kms:ReEncrypt*\",\"kms:GenerateDataKey*\",\"kms:CreateGrant\",\"kms:DescribeKey\"],\"Condition\":{\"StringEquals\":{\"kms:CallerAccount\":\"520666231359\",\"kms:ViaService\":\"elasticfilesystem.ap-northeast-2.amazonaws.com\"}},\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"*\"},\"Resource\":\"*\",\"Sid\":\"Allow access to EFS for all principals in the account that are authorized to use EFS\"},{\"Action\":[\"kms:Describe*\",\"kms:Get*\",\"kms:List*\",\"kms:RevokeGrant\"],\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::520666231359:root\"},\"Resource\":\"*\",\"Sid\":\"Allow direct access to key metadata to the account\"}],\"Version\":\"2012-10-17\"}"
#}

