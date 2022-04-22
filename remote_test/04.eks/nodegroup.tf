################################################################################
################################################################################
#####                                                                      #####
#####   eks node group 을 생성합니다.                                         #####
#####                                                                      #####
################################################################################
################################################################################

data "aws_ssm_parameter" "eksami" {
  name=format("/aws/service/eks/optimized-ami/%s/amazon-linux-2/recommended/image_id", aws_eks_cluster.eks_api.version)
  depends_on = [
    aws_eks_cluster.eks_api
  ]
}


# management nodegroup autoscaling group 을 생성하기 위한 launch template 정의
resource "aws_launch_template" "lt_manage_node" {
  name                    = "launch-template-${local.project_id}-${local.env}-eks-ng-mgmt-1"
  description             = "launch template eks management node group"

  instance_type           = "r5.large"
  image_id                = data.aws_ssm_parameter.eksami.value 

  vpc_security_group_ids = [data.terraform_remote_state.secgrp.outputs.smp_node_security_group_id]#[aws_security_group.sg_allnodes.id]

  user_data  = base64encode(local.eks-node-private-userdata)

  # system spec 에 맞게 수정요함 
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
    aws_eks_cluster.eks_api,
    null_resource.cidr
  ]
}


resource "aws_launch_template" "lt_worker_node" {

  name                    = "launch-template-${local.project_id}-${local.env}-eks-ng-worker-1"
  description             = "launch template eks worker node group"

  instance_type           = "r5.2xlarge"
  image_id                = data.aws_ssm_parameter.eksami.value 

  vpc_security_group_ids  = [data.terraform_remote_state.secgrp.outputs.smp_node_security_group_id]

  user_data               = base64encode(local.eks-node-private-userdata)

  # system spec 에 맞게 수정요함 
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
    aws_eks_node_group.mgmt_node
  ]
}

resource "aws_eks_node_group" "mgmt_node" {
    cluster_name    = aws_eks_cluster.eks_api.name
    node_group_name = "${local.project_id}-${local.env}-eks-ng-mgmt-1"
    node_role_arn   = data.terraform_remote_state.iam.outputs.smp_node_group_role_arn
    //ami_type        = "AL2_x86_64"
    //instance_types  = ["r5.large"]
    capacity_type   = "ON_DEMAND"
    subnet_ids      = [ data.terraform_remote_state.vpc.outputs.smp_unique_backend_subnet_ids[0]] # [aws_subnet.api_private_unique_backend_subnet.0.id ]
    #version           =  "1.21" # EKS Cluster Kubernetes version. 을 기본으로 사용하나 다른버전일경우 명시가 필요함  
    #                     여기서는 버전을 명시 하지 않음으로 해서 EKS Cluster Kubernetes version 을 사용합니다. 

    # system 요구사항에 맞게 수정 필요함 
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
      aws_launch_template.lt_manage_node
		]
}



resource "aws_eks_node_group" "worker_node" {
    cluster_name    = aws_eks_cluster.eks_api.name
    node_group_name = "${local.project_id}-${local.env}-eks-ng-worker-1"
    node_role_arn   = data.terraform_remote_state.iam.outputs.smp_node_group_role_arn
    subnet_ids      = data.terraform_remote_state.vpc.outputs.smp_unique_backend_subnet_ids
    //ami_type        = "AL2_x86_64"
    //instance_types  = ["r5.large"]
    capacity_type   = "ON_DEMAND"
    #version           =  "1.21" # EKS Cluster Kubernetes version. 을 기본으로 사용하나 다른버전일경우 명시가 필요함  
    #                     여기서는 버전을 명시 하지 않음으로 해서 EKS Cluster Kubernetes version 을 사용합니다. 

    # system spec 에 맞게 수정 필요 
    scaling_config {
        desired_size = 2
        max_size     = 4
        min_size     = 2
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

    lifecycle {
      ignore_changes = [scaling_config[0].desired_size]
    }

		depends_on = [
      aws_launch_template.lt_worker_node
		]
}

# coredns addon 은 노드 그룹 생성후에 관리를 수행한다. 
# node 생성후 annotation 작업을 수행한후에 coredns 를 생성해야 오류 없이 빠르게 생성됩니다. 
# 그렇지 않은경우 14 분 이상의 시간이 소요될 수 있으며 terraform 결과로는 오류를 발생하고 
# management console 에서는 생성중으로 panding 된다. 
resource "aws_eks_addon" "addon_coredns" {
  addon_name    	        = "coredns"
  cluster_name  	        = aws_eks_cluster.eks_api.name
  resolve_conflicts       = "OVERWRITE"
  addon_version           = "v1.8.4-eksbuild.1"
  depends_on = [
    null_resource.annotate
  ]
}

