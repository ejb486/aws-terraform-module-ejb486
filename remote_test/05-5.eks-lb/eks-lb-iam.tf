################################################################################
################################################################################
#####                                                                      #####
#####   EKS LB 생성을 위한 iam 정책 및 role 생성                                #####
#####                                                                      #####
################################################################################
################################################################################

## eks cluster 's oidc getting 
data "aws_iam_openid_connect_provider" "eks_cluster_oidc" {
  arn = data.aws_remote_status.eks.outputs.smp_cluster_openid
}

## kubernetes-sig 에서 제공하는 eks lb 를 위한 iam policy json 문자열을 내려 받는다. 
resource "null_resource" "eks_lb_policy" {
    triggers = {
        always_run = timestamp()
    }
    provisioner "local-exec" {
        on_failure  = fail
        when = create
        interpreter = ["/bin/bash", "-c"]
        command     = <<EOT
            curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
        EOT
    }
}

## 위에서 내려받은 json 을 이용하여 
## eks lb 에 대한 iam policy 생성 
resource "aws_iam_policy" "eks_load_balancer_policy" {
    depends_on  = [null_resource.eks_lb_policy]
    name        = "AWSLoadBalancerControllerIAMPolicy"
    path        = "/"
    description = "AWS LoadBalancer Controller IAM Policy"

    policy = file("iam-policy.json")
  
}

## assume role policy document for eks lb 
data "aws_iam_policy_document" "eks_lb_controller_assume" {
    depends_on = [aws_iam_policy.eks_load_balancer_policy]
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
                "system:serviceaccount:kube-system:albc-sa",
            ]
        }
        effect = "Allow"
    }
}

## make iam role for eks lb controller 
resource "aws_iam_role" "eks_lb_controller_role" {
    depends_on = [ data.aws_iam_policy_document.eks_lb_controller_assume ]
    name               = "${var.cluster_name}-alb-ingress"
    assume_role_policy = data.aws_iam_policy_document.eks_lb_controller_assume.json

    tags = merge(local.global_tags, {
        ServiceAccountName      = "albc-sa",
        ServiceAccountNameSpace = "kube-system"
    })
}

## attach policy to role 
resource "aws_iam_role_policy_attachment" "eks_lb_controller" {
    depends_on = [ aws_iam_role.eks_lb_controller_role ]
    role       = aws_iam_role.eks_lb_controller_role.name
    policy_arn = aws_iam_policy.eks_load_balancer_policy.arn
}
