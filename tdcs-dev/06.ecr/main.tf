################################################################################
################################################################################
#####                                                                      #####
#####   provider 와 backend 설정을 정의 합니다.                                 #####
#####                                                                      #####
################################################################################
################################################################################

provider "aws" {
  region  = "ap-northeast-2"
	profile 	=	 "tdcsdev"
}

# get aws caller identity 
data "aws_caller_identity" "current" {}

################################################################################
#####                                                                      #####
#####   resource 를 생성하기 위한 변수값을 local 변수로 정의 합니다.                  #####
#####                                                                      #####
################################################################################
locals {
  account_id   = data.aws_caller_identity.current.account_id
  project_id   = "tdcs"
  env          = "dev"
  servicetitle = "tdcs"
}

terraform {
  backend "s3" {
    bucket 					= "s3-tdcsdev-terraform"               #bucket name
    key         		= "terraform/ecr/terraform.tfstate"    #bucket key 
    region 					= "ap-northeast-2"                     #region 
    encrypt 				= true                                 #encrypt yn 
    dynamodb_table 	= "dydb_tdcsdev_ecr_terraform"         #dynamodb table for locking
  }
}