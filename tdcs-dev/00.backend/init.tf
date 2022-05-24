################################################################################
################################################################################
#####                                                                      #####
#####   tarraform backend status 관리를 위한 s3 bucket & dynamodb table 생성   #####
#####                                                                      #####
################################################################################
################################################################################

provider "aws" {
  region    = "ap-northeast-2" # Please use the default region ID
	profile 	=	 "tdcsdev"
}

variable "stages" {
  type=list(string)
  default=["network", "ec2", "ecs", "batch", "ecr", "efs", "redis", "sg", "aurora", "backup", "alb", "eip", "aurora-parameter", "redis-parameter"]
}

variable "project_id" {
  type = string
  description = "project code "
}
variable "env" {
  type = string
  description = "project environment"
}

locals {
  project_id  = "${var.project_id}"
  env         = "${var.env}"
  profile     = "${var.project_id}${var.env}"
}


# S3 bucket for backend
resource "aws_s3_bucket" "tfstate" {
  bucket = "s3-${local.profile}-terraform"
  object_lock_enabled = true
  tags   = {
    Name = "S3 Remote Terraform State Store"
  }
}

resource aws_s3_bucket_versioning s3_ver {
  bucket = aws_s3_bucket.tfstate.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource aws_s3_bucket_server_side_encryption_configuration s3_enc {
  bucket = aws_s3_bucket.tfstate.bucket
  rule {
    apply_server_side_encryption_by_default {
    sse_algorithm     = "AES256"
    }
  }
}

# DynamoDB for terraform state lock
resource "aws_dynamodb_table" "terraform_state_lock" {
  count           = length(var.stages)
  name            = format("dydb_${local.profile}_%s_terraform",var.stages[count.index])
  hash_key        = "LockID"
  billing_mode    = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags            = {
    "Name" = "DynamoDB Terraform State Lock Table"
  }
}