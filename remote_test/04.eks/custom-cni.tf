
# eks 의 custom network 를 설정 합니다. 
# 이 항목에서의 az, subnet security group cluster name 은 각 프로젝트의 구성에 따라 달라집니다. 
# az 3개 unique subnet 이 3개 인경우 az1 az2 az3 sub1 sub2 sub3 이 인자로 넘어가야 하며 
# shell script 도 수정되어야 합니다. 
resource "null_resource" "cidr" {
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
            sg0=$(echo ${data.terraform_remote_state.secgrp.outputs.smp_cluster_security_group_id})
            cn=$(echo ${aws_eks_cluster.eks_api.name})
            echo $az1 $az2 $sub1 $sub2 $sg0 $cn
            echo -e "\x1B[35mCustom CNI setting (takes a few minutes) ......\x1B[0m"
            ./shell/custom-network.sh $az1 $az2 $sub1 $sub2 $sg0 $cn
        EOT
    }
    depends_on = [
      aws_eks_cluster.eks_api,
      null_resource.gen_backend, 
      aws_eks_addon.addon_kube_proxy,
      aws_eks_addon.addon_vpc_cni
    ]
}
