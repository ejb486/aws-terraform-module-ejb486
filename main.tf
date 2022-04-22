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

  project_id   = "eks-full-sample"
  cluster_name = "eks-full-sample"
  env          = "dev"
  servicetitle = "eks-sample"

  # vpc cidr block list   in vpc resource 
  vpc_cidr = "192.168.0.0/16"
  # vpc cidr block list for aws_vpc_ipv4_cidr_block_association
  vpc_cidrs = [
    "100.64.0.0/16"
  ]
  # cidr block lists for subnet 
  unique_backend_subnet   = ["100.64.34.32/28", "100.64.34.48/28", "100.64.47.64/28"]
  dup_back_subnet         = ["100.64.0.0/23", "100.64.2.0/23", "100.64.4.0/23"]
  private_backend_subnet  = ["192.168.34.80/28", "192.168.34.96/28", "192.168.34.112/28"]
  public_dup_front_subnet = ["100.64.6.0/24", "100.64.7.0/24", "100.64.8.0/24"]

  aws_azs = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]

  private_uniq_backend_subnet_name = "snet-private-uniq-backend"
  private_dub_back_subnet_name     = "snet-private-dup-backend"
  private_backend_subnet_name      = "snet-private-backend"
  public_dup_front_subnet_name     = "snet-public-dup-front"

  global_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    "group"                                       = local.project_id
  }


}