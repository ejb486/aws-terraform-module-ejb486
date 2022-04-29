locals {
  eks-node-private-userdata = <<USERDATA
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks_api.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks_api.certificate_authority[0].data}' '${aws_eks_cluster.eks_api.name}'
--==MYBOUNDARY==--
USERDATA
}