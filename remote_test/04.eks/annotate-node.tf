
# 생성된 management node , worker node 를 annotation 처리를 수행한다. 
resource "null_resource" "annotate" {
    triggers = {
        always_run = timestamp()
    }
    provisioner "local-exec" {
        on_failure  = fail
        when = create
        interpreter = ["/bin/bash", "-c"]
        command     = <<EOT
            az1=$(echo ${local.aws_azs[0]})
            az2=$(echo ${local.aws_azs[1]})
            sub1=$(echo ${data.terraform_remote_state.vpc.outputs.smp_unique_backend_subnet_ids[0]})
            sub2=$(echo ${data.terraform_remote_state.vpc.outputs.smp_unique_backend_subnet_ids[1]})
            sg0=$(echo ${data.terraform_remote_state.secgrp.outputs.smp_node_security_group_id})
            cn=$(echo ${aws_eks_cluster.eks_api.name})
            echo $az1 $az2 $sub1 $sub2 $sg0 $cn
            echo -e "\x1B[35mAnnotate Node(takes a few minutes) ......\x1B[0m"
            ./shell/annotate-node.sh $az1 $az2 $sub1 $sub2 $sg0 $cn
        EOT
    }
    depends_on = [
        aws_eks_node_group.mgmt_node,
        aws_eks_node_group.worker_node
    ]
}