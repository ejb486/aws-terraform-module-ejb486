################################################################################
################################################################################
#####                                                                      #####
#####   EKS EFS csi driver를 위한 iam role 생성                               #####
#####                                                                      #####
################################################################################
################################################################################

## eks cluster 's oidc getting 
data "aws_iam_openid_connect_provider" "eks_cluster_oidc" {
  arn = data.aws_remote_status.eks.outputs.smp_cluster_openid
}

## kubernetes-sig 에서 제공하는 eks lb 를 위한 iam policy json 문자열을 내려 받는다. 
resource "null_resource" "eks_efs_csi_policy" {
    triggers = {
        always_run = timestamp()
    }
    provisioner "local-exec" {
        on_failure  = fail
        when = create
        interpreter = ["/bin/bash", "-c"]
        command     = <<EOT
            curl -o iam-policy-efs-csi.json https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/v1.3.2/docs/iam-policy-example.json
        EOT
    }
}

## 위에서 내려받은 json 을 이용하여 
## eks efs csi driver 에 대한 iam policy 생성 
resource "aws_iam_policy" "eks_efs_csi_policy" {
    depends_on  = [null_resource.eks_efs_csi_policy]
    name        = "${local.cluster_name}-efs-csi-driver"
    path        = "/"
    description = "Policy for the EFS CSI driver"

    policy = file("iam-policy-efs-csi.json")
  
}

## assume role policy document for eks efs csi driver  
data "aws_iam_policy_document" "eks_efs_csi_assume" {
    depends_on = [aws_iam_policy.eks_efs_csi_policy]
    statement {
        actions = ["sts:AssumeRoleWithWebIdentity"]
        principals {
            type        = "Federated"
            identifiers = [data.aws_iam_openid_connect_provider.eks_cluster_oidc.arn]
        }
        condition {
            test     = "StringEquals"
            variable = "${replace(var.cluster_identity_oidc_issuer, "https://", "")}:sub"
            values = [
                "system:serviceaccount:kube-system:aws-efs-csi-driver",
            ]
        }
        effect = "Allow"
    }
}

## make iam role for eks efs csi driver
resource "aws_iam_role" "eks_efs_csi_role" {
    depends_on = [ data.aws_iam_policy_document.eks_efs_csi_assume ]
    name               = "${var.cluster_name}-efs-csi-driver"
    assume_role_policy = data.aws_iam_policy_document.eks_efs_csi_assume.json

    tags = merge(local.global_tags, {
        ServiceAccountName      = "aws-efs-csi-driver",
        ServiceAccountNameSpace = "kube-system"
    })
}

## attach policy to role 
resource "aws_iam_role_policy_attachment" "eks_efs_csi" {
    depends_on = [ aws_iam_role.eks_efs_csi_role ]
    role       = aws_iam_role.eks_efs_csi_role.name
    policy_arn = aws_iam_policy.eks_efs_csi_policy.arn
}