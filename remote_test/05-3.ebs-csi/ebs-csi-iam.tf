resource "aws_iam_role" "csi_driver" {

    name = "eks-cluster-ebscsirole-${local.project_id}"

    assume_role_policy = data.aws_iam_policy_document.assume_role_csi_driver.json
    force_detach_policies = false
    max_session_duration  = 3600

    path                  = "/"
    tags = merge(local.global_tags, {
        ServiceAccountName = "ebs-csi-controller-sa",
        ServiceAccountNameSpace = "kube-system"
    })
}

resource "aws_iam_role_policy" "csi_driver" {
  name = "eks-ebs-csi-driver-${local.project_id}"
  policy = data.aws_iam_policy_document.csi_driver.json
  role = aws_iam_role.csi_driver.id
}

