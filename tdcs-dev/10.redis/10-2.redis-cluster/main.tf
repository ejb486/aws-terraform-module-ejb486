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
    key         		= "terraform/redis/terraform.tfstate"    #bucket key 
    region 					= "ap-northeast-2"                     #region 
    encrypt 				= true                                 #encrypt yn 
    dynamodb_table 	= "dydb_tdcsdev_redis_terraform"         #dynamodb table for locking
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "s3-tdcsdev-terraform"
    key = "terraform/network/terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
    acl = "bucket-owner-full-control"
    profile="tdcsdev"
  }
}

data "terraform_remote_state" "sg" {
  backend = "s3"
  config = {
    bucket = "s3-tdcsdev-terraform"
    key = "terraform/sg/terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
    acl = "bucket-owner-full-control"
    profile="tdcsdev"
  }
}

data "terraform_remote_state" "redis-parameter" {
  backend = "s3"
  config = {
    bucket = "s3-tdcsdev-terraform"
    key = "terraform/redis-parameter/terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
    acl = "bucket-owner-full-control"
    profile="tdcsdev"
  }
}