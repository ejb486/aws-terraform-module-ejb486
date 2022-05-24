#ALB Internet Facing용
resource "aws_lb" "tdcs_alb_internet" {
  name                  = "${local.project_id}-${local.env}-alb-front"
  load_balancer_type    = "application"
  security_groups       = [data.terraform_remote_state.sg.outputs.tdcs_sg_alb]
  internal              = false
  subnets = [data.terraform_remote_state.vpc.outputs.tdcs_public_front_subnet_ids[0], data.terraform_remote_state.vpc.outputs.tdcs_public_front_subnet_ids[1]]
  enable_deletion_protection = true
  
  tags = {
        Name  = "${local.project_id}-${local.env}-alb-front"
        group = "${local.project_id}-${local.env}"
        env   = "${local.env}"
        "creator" = "P092913",
        "operator1" = "P092913",
        "operator2" = "P069329"
  }
}