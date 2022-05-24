################################################################################
#####   							VPC 생성     							#####
################################################################################
# create vpc resource 
resource "aws_vpc" "tdcs_vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "${local.project_id}-dev-vpc"
  }
}

# associate cidr block to vpc 
# reference local variable vpc_cidrs 
resource "aws_vpc_ipv4_cidr_block_association" "vpc_cidr" {
  count      = length(local.vpc_cidrs)
  cidr_block = local.vpc_cidrs[count.index]
  vpc_id     = aws_vpc.tdcs_vpc.id
  depends_on = [
    aws_vpc.tdcs_vpc
  ]
}

################################################################################
#####   					  SUBNET 생성    								#####
################################################################################

## make private unique backend subnets 
resource "aws_subnet" "tdcs_private_unique_backend_subnet" {
  count                   = length(local.private_unique_backend_subnet)
  vpc_id                  = aws_vpc.tdcs_vpc.id
  availability_zone       = local.aws_azs[count.index]
  cidr_block              = local.private_unique_backend_subnet[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.global_tags, {
    Name = "${local.project_id}-${local.private_uniq_backend_subnet_name}${count.index + 1}-${replace(local.private_unique_backend_subnet[count.index], "/", "-")}-${replace(local.aws_azs[count.index], "ap-northeast-", "")}"
  })
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.vpc_cidr
  ]
}

# make private dup backend subnets 
resource "aws_subnet" "tdcs_private_dup_backend_subnet" {
  count                   = length(local.private_dup_backend_subnet)
  vpc_id                  = aws_vpc.tdcs_vpc.id
  availability_zone       = local.aws_azs[count.index]
  cidr_block              = local.private_dup_backend_subnet[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.global_tags, {
    Name = "${local.project_id}-${local.private_dub_backend_subnet_name}${count.index + 1}-${replace(local.private_dup_backend_subnet[count.index], "/", "-")}-${replace(local.aws_azs[count.index], "ap-northeast-", "")}",
  })
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.vpc_cidr
  ]
}

# make private backend subnet 
resource "aws_subnet" "tdcs_private_backend_subnet" {
  count                   = length(local.private_backend_subnet)
  vpc_id                  = aws_vpc.tdcs_vpc.id
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

# make public front subnet 
resource "aws_subnet" "tdcs_public_front_subnet" {
  count                   = length(local.public_front_subnet)
  vpc_id                  = aws_vpc.tdcs_vpc.id
  availability_zone       = local.aws_azs[count.index]
  cidr_block              = local.public_front_subnet[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.global_tags, {
    "Name"                   = "${local.project_id}-${local.public_front_subnet_name}${count.index + 1}-${replace(local.public_front_subnet[count.index], "/", "-")}-${replace(local.aws_azs[count.index], "ap-northeast-", "")}"
  })
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.vpc_cidr
  ]
}

################################################################################
#####   					  VPC FLOW LOG 생성								#####
################################################################################
#vpc flowlog policy (flowlog to s3)
resource "aws_flow_log" "tdcs_vpc_flowlog" {
  log_destination = "arn:aws:s3:::aws-vpcflow-logs-134236154053-ap-northeast-2/Parquet01"
  log_destination_type = "s3"
  log_format = "$${action} $${bytes} $${dstaddr} $${dstport} $${end} $${flow-direction} $${instance-id} $${log-status} $${packets} $${pkt-dst-aws-service} $${pkt-dstaddr} $${pkt-src-aws-service} $${pkt-srcaddr} $${protocol} $${srcaddr} $${srcport} $${start} $${tcp-flags} $${traffic-path} $${vpc-id}"
  traffic_type = "ALL"
  vpc_id = aws_vpc.tdcs_vpc.id
  max_aggregation_interval = "600"

destination_options {
  file_format = "parquet"
  hive_compatible_partitions = false
  per_hour_partition = true
  }
}

################################################################################
#####   			transit / NAT /Internet Gateway  생성					#####
################################################################################
# vpc - transitGW attachment (subenet_ids 설정 필요)
data "aws_ec2_transit_gateway" "tdcs_transit_gateway" {
id = "tgw-072d1d6d6eed05d14"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tdcs_transit_gateway" {
subnet_ids         = [aws_subnet.tdcs_private_unique_backend_subnet.0.id, aws_subnet.tdcs_private_unique_backend_subnet.1.id]
transit_gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id
vpc_id = aws_vpc.tdcs_vpc.id

  tags = {
    "Name" = "${local.project_id}-dev-tg-attach"
   }
 }

#internet gateway 생성 
resource "aws_internet_gateway" "tdcs_igw" {
  vpc_id = aws_vpc.tdcs_vpc.id
  tags = {
    "Name" = "${local.project_id}-dev-igw"
  }
}

# nat gateway 를 위한 eip 생성 az 별 1개씩 생성합니다. 
resource "aws_eip" "tdcs_eip_nat" {
  count = length(local.aws_azs)
  vpc   = true
  tags = {
    "Name" = "${local.project_id}-eip-nat-${replace(local.aws_azs[count.index], "ap-northeast-", "")}"
  }
}

# nat gateway 생성 for public subnet 
resource "aws_nat_gateway" "tdcs_nat_public" {
  count = length(local.aws_azs)

  allocation_id     = element(aws_eip.tdcs_eip_nat.*.id, count.index)
  subnet_id         = element(aws_subnet.tdcs_public_front_subnet.*.id, count.index)
  connectivity_type = "public"

  tags = {
    "Name" = "${local.project_id}-dev-public-natgw-${replace(local.aws_azs[count.index], "ap-northeast-", "")}"
  }
  depends_on = [
    aws_eip.tdcs_eip_nat
  ]
}

# nat gateway 생성 for private subnet 
resource "aws_nat_gateway" "tdcs_nat_private" {
  count = length(local.aws_azs)

  subnet_id         = element(aws_subnet.tdcs_private_unique_backend_subnet.*.id, count.index)
  connectivity_type = "private"

  tags = {
    "Name" = "${local.project_id}-dev-private-natgw-${replace(local.aws_azs[count.index], "ap-northeast-", "")}"
  }
}

################################################################################
#####   						Routing table  생성							#####
################################################################################
# front route table 생성 
resource "aws_route_table" "tdcs_route_front" {
  vpc_id = aws_vpc.tdcs_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tdcs_igw.id
  }
  route {
    cidr_block = "192.168.0.0/16"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  route {
    cidr_block = "100.64.0.0/16"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  tags = {
    "Name" = "${local.project_id}-dev-rt-front"
  }
}

resource "aws_route_table_association" "rout_subnet_front_pub" {
  count          = length(local.public_front_subnet)
  route_table_id = aws_route_table.tdcs_route_front.id
  subnet_id      = element(aws_subnet.tdcs_public_front_subnet.*.id, count.index)
  depends_on = [
    aws_subnet.tdcs_public_front_subnet
  ]
}

# backend pri 2a route table 생성
resource "aws_route_table" "tdcs_route_backend_pri_2a" {
  vpc_id = aws_vpc.tdcs_vpc.id
  route {
    cidr_block = "192.168.0.0/16"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  route {
    cidr_block = "100.64.0.0/16"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  route {
    cidr_block = "172.16.0.0/12"
    gateway_id = aws_nat_gateway.tdcs_nat_private.0.id    
  }
  route {
    cidr_block = "150.0.0.0/8"
    gateway_id = aws_nat_gateway.tdcs_nat_private.0.id    
  }
  route {
    cidr_block = "10.0.0.0/8"
    gateway_id = aws_nat_gateway.tdcs_nat_private.0.id   
  }

  tags = {
    "Name" = "${local.project_id}-dev-rt-backend-pri-2a"
  }

}

resource "aws_route_table_association" "rout_subnet_backend_pri_2a" {
  route_table_id = aws_route_table.tdcs_route_backend_pri_2a.id
  subnet_id      = aws_subnet.tdcs_private_backend_subnet.0.id
  depends_on = [
    aws_subnet.tdcs_private_backend_subnet
  ]
}

# backend pri 2c route table 생성
resource "aws_route_table" "tdcs_route_backend_pri_2c" {
  vpc_id = aws_vpc.tdcs_vpc.id
  route {
    cidr_block = "192.168.0.0/16"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  route {
    cidr_block = "100.64.0.0/16"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  route {
    cidr_block = "172.16.0.0/12"
    gateway_id = aws_nat_gateway.tdcs_nat_private.1.id    
  }
  route {
    cidr_block = "150.0.0.0/8"
    gateway_id = aws_nat_gateway.tdcs_nat_private.1.id    
  }
  route {
    cidr_block = "10.0.0.0/8"
    gateway_id = aws_nat_gateway.tdcs_nat_private.1.id   
  }

  tags = {
    "Name" = "${local.project_id}-dev-rt-backend-pri-2c"
  }

}

resource "aws_route_table_association" "rout_subnet_backend_pri_2c" {
  route_table_id = aws_route_table.tdcs_route_backend_pri_2c.id
  subnet_id      = aws_subnet.tdcs_private_backend_subnet.1.id
  depends_on = [
    aws_subnet.tdcs_private_backend_subnet
  ]
}


# unique backend 2a route table 생성
resource "aws_route_table" "tdcs_route_backend_2a" {
  vpc_id = aws_vpc.tdcs_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tdcs_nat_public.0.id
  }
  route {
    cidr_block = "192.168.0.0/16"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  route {
    cidr_block = "100.64.0.0/16"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  route {
    cidr_block = "172.16.0.0/12"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  route {
    cidr_block = "150.0.0.0/8"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  route {
    cidr_block = "10.0.0.0/8"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  tags = {
    "Name" = "${local.project_id}-dev-rt-unique-backend-2a"
  }
}

resource "aws_route_table_association" "rout_subnet_backend_2a" {
  route_table_id = aws_route_table.tdcs_route_backend_2a.id
  subnet_id      = aws_subnet.tdcs_private_unique_backend_subnet.0.id
}

# unique backend 2c route table 생성
resource "aws_route_table" "tdcs_route_backend_2c" {
  vpc_id = aws_vpc.tdcs_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tdcs_nat_public.1.id
  }
  route {
    cidr_block = "192.168.0.0/16"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  route {
    cidr_block = "100.64.0.0/16"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  route {
    cidr_block = "172.16.0.0/12"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  route {
    cidr_block = "150.0.0.0/8"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  route {
    cidr_block = "10.0.0.0/8"
    gateway_id = data.aws_ec2_transit_gateway.tdcs_transit_gateway.id    
  }
  tags = {
    "Name" = "${local.project_id}-dev-rt-unique-backend-2c"
  }
}

resource "aws_route_table_association" "rout_subnet_backend_2c" {
  route_table_id = aws_route_table.tdcs_route_backend_2c.id
  subnet_id      = aws_subnet.tdcs_private_unique_backend_subnet.1.id
}


# dup backend 2a route table 생성
resource "aws_route_table" "tdcs_route_dup_backend_2a" {
  vpc_id = aws_vpc.tdcs_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tdcs_nat_private.0.id
  }

  tags = {
    "Name" = "${local.project_id}-dev-rt-dup-backend-2a"
  }
}

resource "aws_route_table_association" "rout_subnet_dup_backend_2a" {
  route_table_id = aws_route_table.tdcs_route_dup_backend_2a.id
  subnet_id      = aws_subnet.tdcs_private_dup_backend_subnet.0.id
  depends_on = [
    aws_subnet.tdcs_private_dup_backend_subnet
  ]
}

# dup backend 2c route table 생성
resource "aws_route_table" "tdcs_route_dup_backend_2c" {
  vpc_id = aws_vpc.tdcs_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tdcs_nat_private.1.id
  }

  tags = {
    "Name" = "${local.project_id}-dev-rt-dup-backend-2c"
  }
}

resource "aws_route_table_association" "rout_subnet_dup_backend_2c" {
  route_table_id = aws_route_table.tdcs_route_dup_backend_2c.id
  subnet_id      = aws_subnet.tdcs_private_dup_backend_subnet.1.id
  depends_on = [
    aws_subnet.tdcs_private_dup_backend_subnet
  ]
}