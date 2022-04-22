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
  role_arn = data.terraform_remote_state.iam.outputs.smp_cluster_role_arn
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    security_group_ids      = [data.terraform_remote_state.secgrp.outputs.smp_cluster_security_group_id] # [aws_security_group.sg_cluster.id]
    subnet_ids              = concat(data.terraform_remote_state.vpc.outputs.smp_public_dup_front_subnet_ids, 
                                     data.terraform_remote_state.vpc.outputs.smp_unique_backend_subnet_ids)   # (aws_subnet.api_public_dup_front_subnet.*.id, aws_subnet.api_private_unique_backend_subnet.*.id)
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

# 필요 없음 
#locals {
#  eks_oidc = replace(replace(aws_eks_cluster.eks_api.endpoint, "https://", ""), "/\\..*$/", "")
#}

# kube proxy addon manage 
resource "aws_eks_addon" "addon_kube_proxy" {
  addon_name    = "kube-proxy" 
  cluster_name  = local.cluster_name
  resolve_conflicts = "OVERWRITE"
  addon_version   = "v1.21.2-eksbuild.2"
  depends_on = [
    aws_eks_cluster.eks_api
  ]
}


# vpc-cni addon manage 
resource "aws_eks_addon" "addon_vpc_cni" {
  addon_name    = "vpc-cni" 
  cluster_name  = local.cluster_name
  service_account_role_arn = aws_iam_role.eks_vpc_cni_role.arn
  resolve_conflicts = "OVERWRITE"
  addon_version           = "v1.10.3-eksbuild.1"
  depends_on = [
    aws_eks_cluster.eks_api,
    aws_iam_role.eks_vpc_cni_role, 
    /*aws_eks_node_group.mgmt_node,
    aws_eks_node_group.worker_node*/
  ]
}


# role for eks vpc-cni addon 
resource "aws_iam_role" "eks_vpc_cni_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_vpc_cni_policy_document.json

  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "eks-cluster-vpcCNIRole-${local.project_id}"
  path                  = "/"
  tags = merge(local.global_tags, {
    "Name" = "eks-cluster/ServiceRole"
  })
}

data "aws_iam_policy_document" "eks_vpc_cni_policy_document" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks_cluster_oidc.arn]
    }

  }
}

resource "aws_iam_role_policy_attachment" "eks_vpc_cni_role_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_vpc_cni_role.name
}

# 통신 및 kubectl config 를 생성하고 kubectl 명령어를 수행해본다. 
resource "null_resource" "gen_backend" {
  triggers = {
      always_run = "${timestamp()}"
  }
  depends_on = [aws_eks_cluster.eks_api]
  provisioner "local-exec" {
      on_failure  = fail
      interpreter = ["/bin/bash", "-c"]
      command     = <<EOT
          echo -e "\x1B[31m Warning! Testing Network Connectivity ${aws_eks_cluster.eks_api.name}...should see port 443/tcp open  https\x1B[0m"
          ./shell/test.sh
          echo -e "\x1B[31m Warning! Checking Authorization ${aws_eks_cluster.eks_api.name}...should see Server Version: v1.17.xxx \x1B[0m"
          ./shell/auth.sh
          echo "************************************************************************************"
      EOT
  }
}
