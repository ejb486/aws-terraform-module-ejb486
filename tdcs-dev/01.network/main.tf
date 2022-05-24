################################################################################
################################################################################
#####                                                                      #####
#####   provider 와 backend 설정을 정의 합니다.                                 #####
#####                                                                      #####
################################################################################
################################################################################

provider "aws" {
  region  = "ap-northeast-2"
	#profile 	=	 "tdcsdev"
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
  env          = "prd"
  servicetitle = "tdcs"

  # vpc cidr block list in vpc resource 
  vpc_cidr = "192.168.37.0/26"

  # vpc cidr block list for aws_vpc_ipv4_cidr_block_association
  vpc_cidrs = ["100.64.41.0/27", "100.64.0.0/21"]

  # cidr block lists for subnet 
  private_unique_backend_subnet   = ["100.64.41.0/28", "100.64.41.16/28"]
  private_dup_backend_subnet      = ["100.64.1.0/24", "100.64.2.0/24"]
  private_backend_subnet          = ["192.168.37.32/28", "192.168.37.48/28"]
  public_front_subnet             = ["192.168.37.0/28", "192.168.37.16/28"]

  aws_azs = ["ap-northeast-2a", "ap-northeast-2c"]

  private_uniq_backend_subnet_name = "${local.env}-snet-private-uniq-backend"
  private_dub_backend_subnet_name  = "${local.env}-snet-private-dup-backend"
  private_backend_subnet_name      = "${local.env}-snet-private-backend"
  public_front_subnet_name         = "${local.env}-snet-public-front"

  global_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    "group"                                       = local.project_id
  }
}

terraform {
  backend "s3" {
    bucket 					= "s3-tdcsprd-terraform"               #bucket name
    key         		= "terraform/network/terraform.tfstate"#bucket key 
    region 					= "ap-northeast-2"                     #region 
    encrypt 				= true                                 #encrypt yn 
    dynamodb_table 	= "dydb_tdcsprd_network_terraform"     #dynamodb table for locking
    # backend 를 위한 iam role 은 terraform이 실행되면서 resource 가 provisioning 되는 account 와는 별개의 aws account 입니다. 
    # backend 를 위한 s3, dynamoDB 가 provisioning 되어 있는 account 에서 해당 role 을 s3와 dynamoDB 만  access 권한을 부여하여 terraform 에서 사용하도록 합니다. 
    role_arn        = "arn:aws:iam::875054318754:role/role-for-terraform-cross-account" # iam role for  backend s3 & dynamodb access 
  }
}