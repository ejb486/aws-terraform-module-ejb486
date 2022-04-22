################################################################################
################################################################################
#####                                                                      #####
#####   provider 와 backend 설정을 정의 합니다.                                 #####
#####                                                                      #####
################################################################################
################################################################################

provider "aws" {
  region  = "ap-northeast-2"
  profile = "default" # aws credential profile 
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

  project_id   = "smp"
  env          = "stg"
  cluster_name = "smp-${local.env}-eks"
  servicetitle = "smp"

  # vpc cidr block list   in vpc resource 
  vpc_cidr = "192.168.36.128/26"

  # vpc cidr block list for aws_vpc_ipv4_cidr_block_association
  vpc_cidrs = [
    "100.64.34.96/27", "100.64.0.0/21", "100.64.8.0/23"
  ]

  # cidr block lists for subnet 
  unique_backend_subnet   = ["100.64.34.96/28", "100.64.34.112/28"]
  dup_back_subnet         = ["100.64.0.0/22", "100.64.4.0/22"]
  private_backend_subnet  = ["192.168.36.128/28", "192.168.36.144/28"]
  public_dup_front_subnet = ["100.64.8.0/24", "100.64.9.0/24"]

  aws_azs = ["ap-northeast-2a", "ap-northeast-2c"]

  private_uniq_backend_subnet_name = "snet-private-uniq-backend"
  private_dub_back_subnet_name     = "snet-private-dup-backend"
  private_backend_subnet_name      = "snet-private-backend"
  public_dup_front_subnet_name     = "snet-public-dup-front"

  global_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    "group"                                       = local.project_id
  }


}

terraform {
  backend "s3" {
    bucket 					= "s3-smptttt-terraform"                            #bucket name
    key         		= "terraform/smp/stg/iam/terraform.tfstate"     #bucket key 
    region 					= "ap-northeast-2"                              #region 
    encrypt 				= true                                          #encrypt yn 
    dynamodb_table 	= "dydb_smp_iam_terraform"                      #dynamodb table for locking
  }
}