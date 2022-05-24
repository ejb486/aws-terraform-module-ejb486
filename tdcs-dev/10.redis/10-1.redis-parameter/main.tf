################################################################################
#####                                                                      #####
#####   provider 와 backend 설정을 정의 합니다.                                 #####
#####                                                                      #####
################################################################################
provider "aws" {
  region  = "ap-northeast-2"
	profile 	=	 "tdcsdev"
}

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
  aws_azs = ["ap-northeast-2a", "ap-northeast-2c"]
}

terraform {
  backend "s3" {
    bucket 					= "s3-tdcsdev-terraform"               #bucket name
    key         		= "terraform/redis-parameter/terraform.tfstate"    #bucket key 
    region 					= "ap-northeast-2"                     #region 
    encrypt 				= true                                 #encrypt yn 
    dynamodb_table 	= "dydb_tdcsdev_redis-parameter_terraform"         #dynamodb table for locking
  }
}