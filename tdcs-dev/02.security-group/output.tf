#aurora-security-group 
output "tdcs_sg_aurora" {
    value = aws_security_group.tdcs_sg_aurora.id
}

#efs-security-group
output "tdcs_sg_efs" {
    value = aws_security_group.tdcs_sg_efs.id
}

#alb-security-group
output "tdcs_sg_alb" {
    value = aws_security_group.tdcs_sg_alb.id
}

#ami-security-group
output "tdcs_sg_ami" {
    value = aws_security_group.tdcs_sg_ami.id
}

#chmax-security-group
output "tdcs_sg_ec2_chmax" {
    value = aws_security_group.tdcs_sg_ec2_chmax.id
}

#doss-security-group
output "tdcs_sg_doss" {
    value = aws_security_group.tdcs_sg_doss.id
}

#hips-security-group
output "tdcs_sg_hips" {
    value = aws_security_group.tdcs_sg_hips.id
}

#ecs-security-group
output "tdcs_sg_ecs" {
    value = aws_security_group.tdcs_sg_ecs_insance.id
}

#ec2-bst-security-group
output "tdcs_sg_ec2_bst" {
    value = aws_security_group.tdcs_sg_bst_ec2.id
}

#ec2-if-security-group
output "tdcs_sg_ec2_if" {
    value = aws_security_group.tdcs_sg_if_ec2.id
}

#ec2-jenkins-security-group
output "tdcs_sg_ec2_jenkins" {
    value = aws_security_group.tdcs_sg_jenkins_ec2.id
}

#redis-security-group
output "tdcs_sg_ec2_redis" {
    value = aws_security_group.tdcs_sg_redis.id
}

#batch-security-group
output "tdcs_sg_batch" {
    value = aws_security_group.tdcs_sg_batch_insance.id
}