################################################################################
################################################################################
#####                                                                      #####
#####   eks 관련 security group 을 생성합니다.                                 #####
#####                                                                      #####
################################################################################
################################################################################


################################################################################
#####   			    Security group 생성        							#####
################################################################################
# node security group
resource "aws_security_group" "sg_allnodes" {
  name = format("eks-%s-cluster/ClusterSharedNodeSecurityGroup", local.cluster_name)
  description = "Communication between all nodes in the cluster"
  vpc_id      = aws_vpc.api_vpc.id
  tags = merge(local.global_tags, {
    "Name"                                        = format("eks-%s-cluster/ClusterSharedNodeSecurityGroup", local.cluster_name),
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  })
}

resource "aws_security_group_rule" "sgr_node_all_egress" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg_allnodes.id
}

resource "aws_security_group_rule" "sgr_node_all_ingress_self" {
  type              = "ingress"
  description       = "Allow node to communicate with each other"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg_allnodes.id
  to_port           = 65535
  self              = true
}

resource "aws_security_group_rule" "sgr_node_all_ingress_https" {
  type                     = "ingress"
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_cluster.id
  security_group_id        = aws_security_group.sg_allnodes.id
  depends_on = [
    aws_security_group.sg_cluster
  ]
}

resource "aws_security_group_rule" "sgr_node_all_ingress_others" {
  type                     = "ingress"
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_cluster.id
  security_group_id        = aws_security_group.sg_allnodes.id
}

resource "aws_security_group_rule" "sgr_node_all_ingress_219" {
  type                     = "ingress"
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["203.236.8.219/32"]
  security_group_id        = aws_security_group.sg_allnodes.id
}

# cluster security group 
resource "aws_security_group" "sg_cluster" {
  name = format("eks-%s-cluster/ControlPlaneSecurityGroup", local.cluster_name)
  description = "Communication between the control plane and worker nodegroups"
  vpc_id      = aws_vpc.api_vpc.id
  tags = merge(local.global_tags, {
    "Name" = format("eks-%s-cluster/ControlPlaneSecurityGroup", local.cluster_name), 
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  })
}

resource "aws_security_group_rule" "sgr_eks_all_egress" { #2
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg_cluster.id
}

resource "aws_security_group_rule" "sgr_eks_all_ingerss_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true 
  security_group_id = aws_security_group.sg_cluster.id
}

resource "aws_security_group_rule" "sgr_eks_all_ingerss_all_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = aws_security_group.sg_allnodes.id
  security_group_id = aws_security_group.sg_cluster.id
  depends_on = [
    aws_security_group.sg_allnodes
  ]
}

resource "aws_security_group_rule" "sgr_eks_all_ingress_443" { #1 
  type              = "ingress"
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # 시스템에 맞는 cidr block 적용 
  security_group_id = aws_security_group.sg_cluster.id
}

resource "aws_security_group_rule" "sgr_eks_all_ingress_219" { #1 
  type              = "ingress"
  description       = ""
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["203.236.8.219/32"] # 시스템에 맞는 cidr block 적용 
  security_group_id = aws_security_group.sg_cluster.id
}

# eks 에서 자동으로 생성하는 security group과 연결 
resource "aws_security_group_rule" "sgr_eks_add_auto_create_cluster_sg" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_eks_cluster.eks_api.vpc_config[0].cluster_security_group_id
  security_group_id        = aws_security_group.sg_cluster.id
}

# eks 에서 자동으로 생성하는 security group 에 rule 추가 sg_cluster
resource "aws_security_group_rule" "sgr_eks_auto_create_security_group_ingress_cluster_sg" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_cluster.id
  security_group_id        = aws_eks_cluster.eks_api.vpc_config[0].cluster_security_group_id
}

# eks 에서 자동으로 생성하는 security group 에 rule 추가 sg_allnode
resource "aws_security_group_rule" "sgr_eks_auto_create_security_group_ingress_node_sg" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_allnodes.id
  security_group_id        = aws_eks_cluster.eks_api.vpc_config[0].cluster_security_group_id
}

# eks 에서 자동으로 생성하는 security group 에 rule 추가 sg_allnode
resource "aws_security_group_rule" "sgr_eks_sg_allnode_ingress_auto_create_security_group" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_eks_cluster.eks_api.vpc_config[0].cluster_security_group_id
  security_group_id        = aws_security_group.sg_allnodes.id
}