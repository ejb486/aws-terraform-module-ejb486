################################################################################
################################################################################
#####                                                                      #####
#####   tarraform backend status 관리를 위한 s3 bucket & dynamodb table 생성   #####
#####                                                                      #####
################################################################################
################################################################################

provider "aws" {
  region    = "ap-northeast-2" # Please use the default region ID
	profile 	=	 "default"
}

# S3 bucket for backend
resource "aws_s3_bucket" "tfstate" {
  bucket = "s3-tdcsdev-terraform"

	object_lock_enabled = true
  tags = {
    Name = "S3 Remote Terraform State Store"
  }
}

resource "aws_s3_bucket_versioning" "s3_ver" {
	bucket = aws_s3_bucket.tfstate.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_enc" {
	bucket = aws_s3_bucket.tfstate.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}


# DynamoDB for terraform state lock
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "dydb_tdcsdev_terraform"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    "Name" = "DynamoDB Terraform State Lock Table"
  }
}