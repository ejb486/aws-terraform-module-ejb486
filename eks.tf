################################################################################
################################################################################
#####                                                                      #####
#####               eks cluster 를 생성합니다.                                #####
#####                                                                      #####
################################################################################
################################################################################


#eks cluster 를 생성합니다. 
resource "aws_eks_cluster" "eks_api" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster_ServiceRole.arn
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    security_group_ids      = [aws_security_group.sg_cluster.id]
    subnet_ids              = concat(aws_subnet.api_public_dup_front_subnet.*.id, aws_subnet.api_private_unique_backend_subnet.*.id)
  }

  #kubernetes_network_config {
  #  ip_family         = "ipv4"
  #  service_ipv4_cidr = "10.100.0.0/16"
  #}

  tags = {
    "alpha.eksctl.io/cluster-name"                = local.cluster_name,
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = local.cluster_name,
    "environment"                                 = local.env,
    "personalinformation"                         = "yes",
    "servicetitle"                                = local.servicetitle
  }
}

### get eks tls certificate 
data "tls_certificate" "eks_cluster_tls_certificate" {
  url = aws_eks_cluster.eks_api.identity[0].oidc[0].issuer
  depends_on = [
    aws_eks_cluster.eks_api
  ]
}

# After that create oidc
resource "aws_iam_openid_connect_provider" "eks_cluster_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_tls_certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_api.identity[0].oidc[0].issuer
  depends_on = [
    aws_eks_cluster.eks_api
  ]
}

locals {
  eks_oidc = replace(replace(aws_eks_cluster.eks_api.endpoint, "https://", ""), "/\\..*$/", "")
}

# iam policy for ingress controller 
resource "aws_iam_policy" "ALBIngressControllerIAMPolicy" {
  name        = "${local.cluster_name}_${local.env}_ALBIngressControllerIAMPolicy"
  description = "Policy which will be used by role for service - for creating alb from within cluster by issuing declarative kube commands"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:ModifyListener",
          "wafv2:AssociateWebACL",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:DescribeInstances",
          "wafv2:GetWebACLForResource",
          "elasticloadbalancing:RegisterTargets",
          "iam:ListServerCertificates",
          "wafv2:GetWebACL",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:SetWebAcl",
          "ec2:DescribeInternetGateways",
          "elasticloadbalancing:DescribeLoadBalancers",
          "waf-regional:GetWebACLForResource",
          "acm:GetCertificate",
          "shield:DescribeSubscription",
          "waf-regional:GetWebACL",
          "elasticloadbalancing:CreateRule",
          "ec2:DescribeAccountAttributes",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "waf:GetWebACL",
          "iam:GetServerCertificate",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "ec2:CreateTags",
          "elasticloadbalancing:CreateTargetGroup",
          "ec2:ModifyNetworkInterfaceAttribute",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "ec2:RevokeSecurityGroupIngress",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "shield:CreateProtection",
          "acm:DescribeCertificate",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:DescribeRules",
          "ec2:DescribeSubnets",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "waf-regional:AssociateWebACL",
          "tag:GetResources",
          "ec2:DescribeAddresses",
          "ec2:DeleteTags",
          "shield:DescribeProtection",
          "shield:DeleteProtection",
          "elasticloadbalancing:RemoveListenerCertificates",
          "tag:TagResources",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DescribeListeners",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateSecurityGroup",
          "acm:ListCertificates",
          "elasticloadbalancing:DescribeListenerCertificates",
          "ec2:ModifyInstanceAttribute",
          "elasticloadbalancing:DeleteRule",
          "cognito-idp:DescribeUserPoolClient",
          "ec2:DescribeInstanceStatus",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:CreateLoadBalancer",
          "waf-regional:DisassociateWebACL",
          "elasticloadbalancing:DescribeTags",
          "ec2:DescribeTags",
          "elasticloadbalancing:*",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteTargetGroup",
          "ec2:DescribeSecurityGroups",
          "iam:CreateServiceLinkedRole",
          "ec2:DescribeVpcs",
          "ec2:DeleteSecurityGroup",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:DescribeTargetGroups",
          "shield:ListProtections",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:DeleteListener"
        ],
        Resource = "*"
      }
    ]
  })
}

data "aws_iam_policy_document" "eks_alb_ingress_controller_policy_document" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:alb-ingress-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster_oidc.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      type        = "Federated"
      identifiers = ["${aws_iam_openid_connect_provider.eks_cluster_oidc.arn}"]
    }
  }
}


resource "aws_iam_role" "eks_alb_ingress_controller_role" {
  name = "${local.cluster_name}_${local.env}_ALBIngressController_Role"
  assume_role_policy = data.aws_iam_policy_document.eks_alb_ingress_controller_policy_document.json

  depends_on = [aws_iam_openid_connect_provider.eks_cluster_oidc]

  tags = {
    "ServiceAccountName" = "alb-ingress-controller"
    "ServiceAccountNameSpace" = "kube-system"
  }
}

# attach police 
resource "aws_iam_role_policy_attachment" "alb_ingress_controller_role_ALBIngressControllerIAMPolicy" {
  policy_arn = aws_iam_policy.ALBIngressControllerIAMPolicy.arn
  role       = aws_iam_role.eks_alb_ingress_controller_role.name
  depends_on = [aws_iam_role.eks_alb_ingress_controller_role]
}

resource "aws_iam_role_policy_attachment" "alb_ingress_controller_role_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_alb_ingress_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  depends_on = [aws_iam_role.eks_alb_ingress_controller_role]
}


# eks addon 생성 
resource "aws_eks_addon" "addon_coredns" {
  addon_name    	= "coredns" 
  cluster_name  	= local.cluster_name
  depends_on = [
    aws_eks_node_group.mgmt_node,
    aws_eks_node_group.worker_node
  ]
}

resource "aws_eks_addon" "addon_kube_proxy" {
  addon_name    = "kube-proxy" 
  cluster_name  = local.cluster_name
  depends_on = [
    aws_eks_cluster.eks_api
  ]
}

resource "aws_eks_addon" "addon_vpc_cni" {
  addon_name    = "vpc-cni" 
  cluster_name  = local.cluster_name
  service_account_role_arn = aws_iam_role.eks_alb_ingress_controller_role.arn
  depends_on = [
    aws_eks_cluster.eks_api,
    aws_iam_role.eks_alb_ingress_controller_role
  ]
}


