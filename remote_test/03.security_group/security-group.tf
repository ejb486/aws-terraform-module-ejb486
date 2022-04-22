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
# cluster security group 
resource "aws_security_group" "sg_cluster" {
  name = format("eks-%s-cluster/ControlPlaneSecurityGroup", local.cluster_name)
  description = "Communication between the control plane and worker nodegroups"
  vpc_id      = data.terraform_remote_state.vpc.outputs.smp_vpc_id
  tags = merge(local.global_tags, {
    "Name"                                        = format("eks-%s-cluster/ControlPlaneSecurityGroup", local.cluster_name), 
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  })
}

# cluster security group egress rule 
resource "aws_security_group_rule" "sgr_eks_all_egress" { 
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg_cluster.id
}

# cluster security group ingerss all self 
resource "aws_security_group_rule" "sgr_eks_ingress_all_self" { 
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.sg_cluster.id
}

# cluster security group ingerss all node security group 
resource "aws_security_group_rule" "sgr_eks_ingress_all_sg_allnode" { 
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

# node security group
resource "aws_security_group" "sg_allnodes" {
  name = format("eks-%s-cluster/ClusterSharedNodeSecurityGroup", local.cluster_name)
  description = "Communication between all nodes in the cluster"
  vpc_id      = data.terraform_remote_state.vpc.outputs.smp_vpc_id
  tags = merge(local.global_tags, {
    "Name"                                        = format("eks-%s-cluster/ClusterSharedNodeSecurityGroup", local.cluster_name),
    "eks/cluster-name"                            = local.cluster_name,
    "alpha.eksctl.io/cluster-name"                = local.cluster_name,
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  })
}

# node security group egress all 
resource "aws_security_group_rule" "sgr_allnode_all_egress" { 
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg_allnodes.id
}

# node security group ingerss all self 
resource "aws_security_group_rule" "sgr_allnodes_ingress_all_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true 
  security_group_id = aws_security_group.sg_allnodes.id
}


# node security group ingerss all cluster security group 
resource "aws_security_group_rule" "sgr_allnode_ingress_all_sg_cluster" { 
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = aws_security_group.sg_cluster.id
  security_group_id = aws_security_group.sg_allnodes.id
}

