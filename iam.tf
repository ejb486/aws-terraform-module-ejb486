################################################################################
################################################################################
#####                                                                      #####
#####   eks 관련 iam role 을 생성합니다.`                                      #####
#####                                                                      #####
################################################################################
################################################################################



resource "aws_iam_role" "eks_cluster_ServiceRole" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = [
              "eks-fargate-pods.amazonaws.com",
              "eks.amazonaws.com",
            ]
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "eks-cluster-ServiceRole-${local.project_id}"
  path                  = "/"
  tags = merge(local.global_tags, {
    "Name" = "eks-cluster/ServiceRole"
  })
}

resource "aws_iam_role" "eks_nodegroup_NodeInstanceRole" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "eks-nodegroup-NodeInstanceRole-${local.project_id}"
  path                  = "/"
  tags = merge(local.global_tags, {
    "Name" = "eks-nodegroup-${local.project_id}/NodeInstanceRole"
  })
}

resource "aws_iam_role_policy" "eks_cluster_ServiceRole_PolicyCloudWatchMetrics" {
  name = "eks-cluster-PolicyCloudWatchMetrics-${local.project_id}"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "cloudwatch:PutMetricData",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
  role = aws_iam_role.eks_cluster_ServiceRole.id
}

resource "aws_iam_role_policy" "eks_cluster_ServiceRole_PolicyELBPermissions" {
  name = "eks-cluster-PolicyELBPermissions-${local.project_id}"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeAddresses",
            "ec2:DescribeInternetGateways"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
  role = aws_iam_role.eks_cluster_ServiceRole.id
}

resource "aws_iam_role_policy" "eks_nodegroup_NodeInstanceRole_PolicyAutoScaling" {
  name = "eks-nodegroup-ng-maneksami2-PolicyAutoScaling"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeTags",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
            "ec2:DescribeLaunchTemplateVersions",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
  role = aws_iam_role.eks_nodegroup_NodeInstanceRole.id
}

resource "aws_iam_role_policy_attachment" "eks_cluster_ServiceRole_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_ServiceRole.id
}

resource "aws_iam_role_policy_attachment" "eks_cluster_ServiceRole_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_ServiceRole.id
}



resource "aws_iam_role_policy_attachment" "eks_nodegroup_NodeInstanceRole_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_NodeInstanceRole.id
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_NodeInstanceRole_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_NodeInstanceRole.id
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_NodeInstanceRole_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_NodeInstanceRole.id
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_NodeInstanceRole_CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks_nodegroup_NodeInstanceRole.id
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_NodeInstanceRole_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_nodegroup_NodeInstanceRole.id
}





resource "aws_iam_role" "eks_vpc_cni_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = [
              "eks-fargate-pods.amazonaws.com",
              "eks.amazonaws.com",
            ]
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "eks-cluster-vpcCNIRole-${local.project_id}"
  path                  = "/"
  tags = merge(local.global_tags, {
    "Name" = "eks-cluster/ServiceRole"
  })
}

