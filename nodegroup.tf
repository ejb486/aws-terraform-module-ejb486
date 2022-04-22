################################################################################
################################################################################
#####                                                                      #####
#####   eks node group 을 생성합니다.                                         #####
#####                                                                      #####
################################################################################
################################################################################


# management nodegroup autoscaling group 을 생성하기 위한 launch template 정의
resource "aws_launch_template" "lt_manage_node" {
  name                   = "launch-template-${local.project_id}-${local.env}-eks-ng-mgmt-1"
  description            = "launch template eks management node group"
  vpc_security_group_ids = [aws_security_group.sg_allnodes.id]

  user_data  = base64encode(templatefile("./template/node_user_data_tmpl.tpl", 
                                          { ClusterName = local.cluster_name, 
                                            BootstrapArguments = "--apiserver-endpoint '${aws_eks_cluster.eks_api.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks_api.certificate_authority[0].data}'"}))

  

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp3"
      iops        = 3000
      throughput  = 125
    }
    no_device    = ""
    virtual_name = ""
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name"                           = "${local.project_id}-${local.env}-eks-ng-mgmt-1"
    }
  }
  depends_on = [
    aws_eks_cluster.eks_api
  ]
}


resource "aws_launch_template" "lt_worker_node" {

  name        = "launch-template-${local.project_id}-${local.env}-eks-ng-worker-1"
  description = "launch template eks worker node group"
  vpc_security_group_ids = [aws_security_group.sg_allnodes.id]

  user_data  = base64encode(templatefile("./template/node_user_data_tmpl.tpl", 
                                          { ClusterName = local.cluster_name, 
                                            BootstrapArguments = "--apiserver-endpoint '${aws_eks_cluster.eks_api.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks_api.certificate_authority[0].data}'"}))

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp3"
      iops        = 3000
      throughput  = 125
    }
    no_device    = ""
    virtual_name = ""
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name"                           = "${local.project_id}-${local.env}-eks-ng-worker-1"
    }
  }

  depends_on = [
    aws_eks_cluster.eks_api
  ]

}

resource "aws_eks_node_group" "mgmt_node" {
    cluster_name    = aws_eks_cluster.eks_api.name
    node_group_name = "${local.project_id}-${local.env}-eks-ng-mgmt-1"
    node_role_arn   = aws_iam_role.eks_nodegroup_NodeInstanceRole.arn
    subnet_ids      = aws_subnet.api_private_unique_backend_subnet.*.id
    ami_type        = "AL2_x86_64"
    instance_types  = ["r5.large"]
    capacity_type   = "ON_DEMAND"
    #version           =  "1.21" # EKS Cluster Kubernetes version. 을 기본으로 사용하나 다른버전일경우 명시가 필요함  
    #                     여기서는 버전을 명시 하지 않음으로 해서 EKS Cluster Kubernetes version 을 사용합니다. 

    scaling_config {
        desired_size = 1
        max_size     = 1
        min_size     = 1
    }

    update_config {
        max_unavailable = 1
    }

    labels = {
        "alpha.eksctl.io/cluster-name"   = aws_eks_cluster.eks_api.name
        "alpha.eksctl.io/nodegroup-name" = "${local.project_id}-${local.env}-eks-ng-mgmt-1"
        "role"                           = "management"
        "eks/cluster-name"               = aws_eks_cluster.eks_api.name
        "eks/nodegroup-name"             = "${local.project_id}-${local.env}-eks-ng-mgmt-1"
    }

    taint {
            effect  = "NO_SCHEDULE"
            key     = "management"
            value   = true
    }

    launch_template {
        id      = aws_launch_template.lt_manage_node.id
        version = "1"
    }

    tags = {
        "alpha.eksctl.io/cluster-name"                = local.cluster_name,
        "kubernetes.io/cluster/${local.cluster_name}" = "owned",
        "alpha.eksctl.io/nodegroup-name"              = "${local.project_id}-${local.env}-eks-ng-mgmt-1"
        "alpha.eksctl.io/nodegroup-type"              = "managed",
        "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = local.cluster_name,
        "eks/cluster-name"                            = local.cluster_name,
        "eks/nodegroup-name"                          = "${local.project_id}-${local.env}-eks-ng-mgmt-1"
        "eks/nodegroup-type"                          = "managed"
        "environment"                                 = local.env,
        "nodegroup-role"                              = "management",
        "personalinformation"                         = "yes",
        "servicetitle"                                = local.servicetitle
    }

	depends_on = [
  		aws_iam_role_policy_attachment.eks_nodegroup_NodeInstanceRole_AmazonEC2ContainerRegistryReadOnly,
			aws_iam_role_policy_attachment.eks_nodegroup_NodeInstanceRole_AmazonEKS_CNI_Policy,
			aws_iam_role_policy_attachment.eks_nodegroup_NodeInstanceRole_AmazonEKSWorkerNodePolicy, 
      aws_iam_role_policy_attachment.eks_nodegroup_NodeInstanceRole_CloudWatchAgentServerPolicy,
      aws_iam_role_policy_attachment.eks_nodegroup_NodeInstanceRole_AmazonSSMManagedInstanceCore
		] 
}



resource "aws_eks_node_group" "worker_node" {
    cluster_name    = aws_eks_cluster.eks_api.name
    node_group_name = "${local.project_id}-${local.env}-eks-ng-worker-1"
    node_role_arn   = aws_iam_role.eks_nodegroup_NodeInstanceRole.arn
    subnet_ids      = aws_subnet.api_private_unique_backend_subnet.*.id
    ami_type        = "AL2_x86_64"
    instance_types  = ["r5.2xlarge"]
    capacity_type   = "ON_DEMAND"
    #version           =  "1.21" # EKS Cluster Kubernetes version. 을 기본으로 사용하나 다른버전일경우 명시가 필요함  
    #                     여기서는 버전을 명시 하지 않음으로 해서 EKS Cluster Kubernetes version 을 사용합니다. 

    scaling_config {
        desired_size = 5
        max_size     = 6
        min_size     = 5
    }

    update_config {
        max_unavailable = 1
    }

    labels = {
        "alpha.eksctl.io/cluster-name"   = aws_eks_cluster.eks_api.name
        "alpha.eksctl.io/nodegroup-name" = "${local.project_id}-${local.env}-eks-ng-worker-1"
        "role"                           = "worker"
        "eks/cluster-name"                = aws_eks_cluster.eks_api.name
        "eks/nodegroup-name"             = "${local.project_id}-${local.env}-eks-ng-worker-1"
    }

    taint {
            effect  = "NO_SCHEDULE"
            key     = "management"
            value   = true
    }

    launch_template {
        id      = aws_launch_template.lt_worker_node.id
        version = "1"
    }

    tags = {
        "alpha.eksctl.io/cluster-name"                = local.cluster_name,
        "kubernetes.io/cluster/${local.cluster_name}" = "owned",
        "alpha.eksctl.io/nodegroup-name"              = "${local.project_id}-${local.env}-eks-ng-worker-1",
        "alpha.eksctl.io/nodegroup-type"              = "managed",
        "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = local.cluster_name,
        "eks/cluster-name"                            = local.cluster_name,
        "eks/nodegroup-name"                          = "${local.project_id}-${local.env}-eks-ng-worker-1",
        "eks/nodegroup-type"                          = "managed"
        "environment"                                 = local.env,
        "nodegroup-role"                              = "worker",
        "personalinformation"                         = "yes",
        "servicetitle"                                = local.servicetitle
    }

		depends_on = [
  		aws_iam_role_policy_attachment.eks_nodegroup_NodeInstanceRole_AmazonEC2ContainerRegistryReadOnly,
			aws_iam_role_policy_attachment.eks_nodegroup_NodeInstanceRole_AmazonEKS_CNI_Policy,
			aws_iam_role_policy_attachment.eks_nodegroup_NodeInstanceRole_AmazonEKSWorkerNodePolicy
		] 
}