
################################################################################
################################################################################
#####                                                                      #####
#####   aws VPC 부터 시작하는 네트 워크 리소스 를  생성합니다.                        #####
#####                                                                      #####
################################################################################
################################################################################


################################################################################
#####   							VPC 생성     							#####
################################################################################
# create vpc resource 
resource "aws_vpc" "api_vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "${local.project_id}-vpc"
  }
}

# associate cidr block to vpc 
# reference local variable vpc_cidrs 
resource "aws_vpc_ipv4_cidr_block_association" "vpc_cidr" {
  count      = length(local.vpc_cidrs)
  cidr_block = local.vpc_cidrs[count.index]
  vpc_id     = aws_vpc.api_vpc.id
  depends_on = [
    aws_vpc.api_vpc
  ]
}

################################################################################
#####   					  SUBNET 생성    								#####
################################################################################

## make private unique backend subnets 
resource "aws_subnet" "api_private_unique_backend_subnet" {
  count                   = length(local.unique_backend_subnet)
  vpc_id                  = aws_vpc.api_vpc.id
  availability_zone       = local.aws_azs[count.index]
  cidr_block              = local.unique_backend_subnet[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.global_tags, {
    Name                              = "${local.project_id}-${local.private_uniq_backend_subnet_name}${count.index + 1}-${replace(local.unique_backend_subnet[count.index], "/", "-")}-${replace(local.aws_azs[count.index], "ap-northeast-", "")}",
    "kubernetes.io/role/internal-elb" = "1"
  })
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.vpc_cidr
  ]
}

# make private dup backend subnets 
resource "aws_subnet" "api_private_dup_backend_subnet" {
  count                   = length(local.dup_back_subnet)
  vpc_id                  = aws_vpc.api_vpc.id
  availability_zone       = local.aws_azs[count.index]
  cidr_block              = local.dup_back_subnet[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.global_tags, {
    Name = "${local.project_id}-${local.private_dub_back_subnet_name}${count.index + 1}-${replace(local.dup_back_subnet[count.index], "/", "-")}-${replace(local.aws_azs[count.index], "ap-northeast-", "")}",
  })
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.vpc_cidr
  ]
}

# make private backend subnet 
resource "aws_subnet" "api_private_backend_subnet" {
  count                   = length(local.private_backend_subnet)
  vpc_id                  = aws_vpc.api_vpc.id
  availability_zone       = local.aws_azs[count.index]
  cidr_block              = local.private_backend_subnet[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.global_tags, {
    Name = "${local.project_id}-${local.private_backend_subnet_name}${count.index + 1}-${replace(local.private_backend_subnet[count.index], "/", "-")}-${replace(local.aws_azs[count.index], "ap-northeast-", "")}",
  })
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.vpc_cidr
  ]
}

# make public dup front subnet 
resource "aws_subnet" "api_public_dup_front_subnet" {
  count                   = length(local.public_dup_front_subnet)
  vpc_id                  = aws_vpc.api_vpc.id
  availability_zone       = local.aws_azs[count.index]
  cidr_block              = local.public_dup_front_subnet[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.global_tags, {
    "Name"                   = "${local.project_id}-${local.public_dup_front_subnet_name}${count.index + 1}-${replace(local.public_dup_front_subnet[count.index], "/", "-")}-${replace(local.aws_azs[count.index], "ap-northeast-", "")}",
    "kubernetes.io/role/elb" = "1"
  })
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.vpc_cidr
  ]
}

################################################################################
#####   					  VPC FLOW LOG 생성								#####
################################################################################

# make s3 bucket for flow log 
# 실제 운영에서는 s3 bucket 을 생성하지 않고 arn 을 가져와 사용합니다. 
resource "aws_s3_bucket" "flow_log_bucket" {
  bucket = "${local.project_id}-flow-log-s3"
  tags = {
    Name = "flow log s3"
  }
}

# make flow log object 
resource "aws_flow_log" "vpc_flow" {
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.api_vpc.id
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.flow_log_bucket.arn # 실제 운영에서는 s3 bucket 을 생성하지 않고 기 생성된 s3의 arn 을 가져와 사용합니다. 
  log_format           = "$${action} $${bytes} $${dstaddr} $${dstport} $${end} $${flow-direction} $${instance-id} $${log-status} $${packets} $${pkt-dst-aws-service} $${pkt-dstaddr} $${pkt-src-aws-service} $${pkt-srcaddr} $${protocol} $${srcaddr} $${srcport} $${start} $${tcp-flags} $${traffic-path} $${vpc-id}"

  destination_options {
    file_format                = "parquet"
    hive_compatible_partitions = false
    per_hour_partition         = true
  }
}

################################################################################
#####   			transit / NAT /Internet Gateway  생성					#####
################################################################################

#internet gateway 생성 
resource "aws_internet_gateway" "api_igw" {
  vpc_id = aws_vpc.api_vpc.id
  tags = {
    "Name" = "${local.project_id}-igw"
  }
}

# nat gateway 를 위한 eip 생성 az 별 1개씩 생성합니다. 
resource "aws_eip" "api_eip_nat" {
  count = length(local.aws_azs)
  vpc   = true
  tags = {
    "Name" = "${local.project_id}-eip-nat-${replace(local.aws_azs[count.index], "ap-northeast-", "")}"
  }
}

# nat gateway 생성 for public subnet 
resource "aws_nat_gateway" "api_nat_front" {
  count = length(local.aws_azs)

  allocation_id     = element(aws_eip.api_eip_nat.*.id, count.index)
  subnet_id         = element(aws_subnet.api_public_dup_front_subnet.*.id, count.index)
  connectivity_type = "public"

  tags = {
    "Name" = "${local.project_id}-nat-front1-${replace(local.aws_azs[count.index], "ap-northeast-", "")}"
  }
  depends_on = [
    aws_eip.api_eip_nat
  ]
}


# transit gateway 생성 
#resource "aws_ec2_transit_gateway" "api_tgw1" {
#  	description 					= "TGW-To-LandingZone-Default"
#  	default_route_table_association = "disable"
#  	default_route_table_propagation = "disable"
#  	amazon_side_asn 				= 64811
#
#}
#resource "aws_ec2_transit_gateway" "api_tgw2" {
#  description 						= "TGW-To-PangyoDT-Interconnect"
#  default_route_table_association 	= "disable"
#  default_route_table_propagation 	= "disable"
#  amazon_side_asn 					= 64820
#}
#
#resource "aws_ec2_transit_gateway_vpc_attachment" "api_tgc" {
#  	subnet_ids = api_private_unique_backend_subnet.*.id 
#  	transit_gateway_id = aws_ec2_transit_gateway.api_tgw1.id
#  	vpc_id = aws_vpc.api_vpc.id
#
#  	tags = {
#          Name = "${local.project_id}-tgw"
#	}
#
#}

################################################################################
#####   						Routing table  생성							#####
################################################################################
# front route table 생성 
resource "aws_route_table" "api_route_front" {
  vpc_id = aws_vpc.api_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.api_igw.id
  }
  tags = {
    "Name" = "${local.project_id}-rtb-front"
  }
}

resource "aws_route_table_association" "rout_subnet_front_pub" {
  count          = length(local.public_dup_front_subnet)
  route_table_id = aws_route_table.api_route_front.id
  subnet_id      = element(aws_subnet.api_public_dup_front_subnet.*.id, count.index)
  depends_on = [
    aws_subnet.api_public_dup_front_subnet
  ]
}

# backend pri route table 생성
resource "aws_route_table" "api_route_backend_pri" {
  vpc_id = aws_vpc.api_vpc.id
 # route {
 #   cidr_block = "0.0.0.0/0"
 #   gateway_id = aws_internet_gateway.api_igw.id
 # }
  tags = {
    "Name" = "${local.project_id}-prd-rt-backend-pri"
  }
}

resource "aws_route_table_association" "rout_subnet_backend_pri" {
  count          = length(local.private_backend_subnet)
  route_table_id = aws_route_table.api_route_backend_pri.id
  subnet_id      = element(aws_subnet.api_private_backend_subnet.*.id, count.index)
  depends_on = [
    aws_subnet.api_private_backend_subnet
  ]
}

# backend 2a route table 생성
resource "aws_route_table" "api_route_backend_2a" {
  vpc_id = aws_vpc.api_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.api_nat_front.0.id
  }
  tags = {
    "Name" = "${local.project_id}-stg-rt-backend-2a"
  }
}

resource "aws_route_table_association" "rout_subnet_backend_2a" {
  route_table_id = aws_route_table.api_route_backend_2a.id
  subnet_id      = aws_subnet.api_private_unique_backend_subnet.0.id
  depends_on = [
    aws_subnet.api_private_unique_backend_subnet
  ]
}

# backend 2c route table 생성
resource "aws_route_table" "api_route_backend_2c" {
  vpc_id = aws_vpc.api_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.api_nat_front.1.id
  }
  tags = {
    "Name" = "${local.project_id}-stg-rt-backend-2c"
  }
}

resource "aws_route_table_association" "rout_subnet_backend_2c" {
  route_table_id = aws_route_table.api_route_backend_2c.id
  subnet_id      = aws_subnet.api_private_unique_backend_subnet.1.id
  depends_on = [
    aws_subnet.api_private_unique_backend_subnet
  ]
}
