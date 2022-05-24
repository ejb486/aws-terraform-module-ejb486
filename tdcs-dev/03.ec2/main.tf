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
  cluster_name = "eks-full-sample"
  project_id   = "tdcs"
  env          = "dev"
  servicetitle = "tdcs"

  # vpc cidr block list in vpc resource 
  vpc_cidr = "192.168.37.0/26"

  # vpc cidr block list for aws_vpc_ipv4_cidr_block_association
  vpc_cidrs = [
    "100.64.41.0/27", "100.64.0.0/21"
  ]
  # cidr block lists for subnet 
  private_unique_backend_subnet   = ["100.64.41.0/28", "100.64.41.16/28"]
  private_dup_backend_subnet      = ["100.64.1.0/24", "100.64.2.0/24"]
  private_backend_subnet          = ["192.168.37.32/28", "192.168.37.48/28"]
  public_front_subnet             = ["192.168.37.0/28", "192.168.37.16/28"]

  aws_azs = ["ap-northeast-2a", "ap-northeast-2c"]

  private_uniq_backend_subnet_name = "dev-snet-private-uniq-backend"
  private_dub_backend_subnet_name  = "dev-snet-private-dup-backend"
  private_backend_subnet_name      = "dev-snet-private-backend"
  public_front_subnet_name         = "dev-snet-public-front"

  global_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    "group"                                       = local.project_id
  }
}

terraform {
  backend "s3" {
    bucket 					= "s3-tdcsdev-terraform"               #bucket name
    key         		= "terraform/ec2/terraform.tfstate"    #bucket key 
    region 					= "ap-northeast-2"                     #region 
    encrypt 				= true                                 #encrypt yn 
    dynamodb_table 	= "dydb_tdcsdev_ec2_terraform"            #dynamodb table for locking
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