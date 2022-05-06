################################################################################
################################################################################
#####                                                                      #####
#####   EKS lb controller 생성을 위한 helm chart                              #####
#####                                                                      #####
################################################################################
################################################################################

# helm chart 생성 

resource "helm_release" "lb_controller" {
  depends_on = [aws_iam_role_policy_attachment.eks_lb_controller]
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.ghthub.io/eks-chart"
  version    = "1.3.3"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = local.cluster_name
  }
  # RBAC 리소스를 생성
  set {
    name  = "rbac.create"
    value = "true"
  }
  # 서비스어카운트를 생성
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  # 사용할 서비스어카운트 이름
  set {
    name  = "serviceAccount.name"
    value = "albc-sa"
  }
  ## service account 에 iam arn 할당 
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.eks_lb_controller_role.arn
  }
  # tag setting 
  set {
    name  = "defaultTags.personalinformation"
    value = "yes"
  }
  set {
    name  = "defaultTags.servicetitle"
    value = local.servicetitle
  }
  set {
    name  = "defaultTags.environment"
    value = local.env
  }

}