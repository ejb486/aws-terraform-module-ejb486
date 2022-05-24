# Redis용 security group
resource "aws_security_group" "tdcs_sg_redis" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.tdcs_vpc_id
  name        = "${local.project_id}-${local.env}-an2-sgroup-redis"
  description = "${local.project_id}-${local.env}-an2-sgroup-redis"
	
  tags = {
	Name = "${local.project_id}-${local.env}-an2-sgroup-redis" 
    }
}

resource "aws_security_group_rule" "tdcs_sgr_redis_egress" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.tdcs_sg_redis.id
}