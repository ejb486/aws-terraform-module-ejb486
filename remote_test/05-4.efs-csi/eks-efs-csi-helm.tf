################################################################################
################################################################################
#####                                                                      #####
#####   EKS efs csi driver 생성을 위한 helm chart                             #####
#####                                                                      #####
################################################################################
################################################################################

locals {
    efs_service_account_name = "aws-efs-csi-driver"
}

# helm chart 생성 
resource "helm_release" "eks_efs_csi" {
    depends_on = [aws_iam_role_policy_attachment.eks_efs_csi]
    name       = "aws-efs-csi-driver"
    chart      = "aws-efs-csi-driver"
    repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
    version    = "2.2.3"
    namespace  = "kube-system"

    #controller.serviceaccount 생성 
    set {
        name  = "controller.serviceAccount.create"
        value = "true"
    }
    # controller service account name set 
    set {
        name  = "controller.serviceAccount.name"
        value = local.efs_service_account_name
    }
    # service account 에 iam role arn 할당 
    set {
        name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = aws_iam_role.eks_efs_csi_role.arn
    }
    # node service accoutn create 
    # controller service account 와 같은 것을 사용하도록 하였기 때문에 false 로 설정 
    set {
        name = "node.serviceAccount.create"
        # We're using the same service account for both the nodes and controllers,
        # and we're already creating the service account in the controller config
        # above.
        value = "false"
    }
    # node service account name set 
    set {
        name  = "node.serviceAccount.name"
        value = local.efs_service_account_name
    }
    # service account 에 iam role arn 할당 
    set {
        name  = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = aws_iam_role.eks_efs_csi_role.arn
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