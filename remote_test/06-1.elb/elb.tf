################################################################################
################################################################################
#####                                                                      #####
#####   elastic load balancer를 생성합니다.                                   #####
#####                                                                      #####
################################################################################
################################################################################



# front network loadbalancer 를 위한 eip 생성 az 별 1개씩 생성합니다. 
resource "aws_eip" "eip_nlb" {
  count = length(local.aws_azs)
  vpc   = true
  tags = {
    "Name" = "${local.project_id}-eip-nlb-${replace(local.aws_azs[count.index], "ap-northeast-", "")}"
  }
}

# front network loadbalancer 생성 각 az별 front subnet 에 eip 매핑 
resource "aws_lb" "network_lb" {
    name                    = "${local.project_id}-${local.env}-nlb-front"
    internal                = false
    load_balancer_type      = "network"
    ip_address_type         = "ipv4"

    subnet_mapping {
        subnet_id     = element(data.terraform_remote_state.vpc.outputs.smp_public_dup_front_subnet_ids, 0) #element(aws_subnet.api_public_dup_front_subnet.*.id, 0)
        allocation_id = element(aws_eip.eip_nlb.*.id, 0) 
    }
    subnet_mapping {
        subnet_id     = element(data.terraform_remote_state.vpc.outputs.smp_public_dup_front_subnet_ids, 1)
        allocation_id = element(aws_eip.eip_nlb.*.id, 1) 
    }
    depends_on = [
      aws_eip.eip_nlb
    ]
}



# front network loadbalancer 의 80 port listener 를 위한 terget group 
resource "aws_lb_target_group" "nlb_tg_front_80" {
    name                = "${local.project_id}-nlb-tg-front-80"
    target_type         = "alb"
    port                = 80
    protocol            = "TCP"
    vpc_id              = data.terraform_remote_state.vpc.outputs.smp_vpc_id  #aws_vpc.api_vpc.id

    preserve_client_ip = true 

    stickiness {
        cookie_duration = 0
        cookie_name     = ""
        enabled         = false
        type            = "source_ip"
    }

    health_check {
        enabled             = true
        healthy_threshold   = 3
        interval            = 30
        matcher             = "200-399"
        path                = "/actuator/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 6
        unhealthy_threshold = 3
    }
}

# terget group 에 terget 설정 
#resource "aws_lb_target_group_attachment" "nlb_tg_front_attach_80" {
#  target_group_arn = aws_lb_target_group.nlb_tg_front_80.arn
#  target_id        = aws_lb_listener.lis_alb_front.arn
#  port             = 80
#}

# front network loadbalancer 의 443 port listener 를 위한 terget group 
resource "aws_lb_target_group" "nlb_tg_front_443" {
    name                = "${local.project_id}-nlb-tg-front-443"
    target_type         = "alb"
    port                = 443
    protocol            = "TCP"
    vpc_id              = data.terraform_remote_state.vpc.outputs.smp_vpc_id #aws_vpc.api_vpc.id

    preserve_client_ip = true 

    stickiness {
        cookie_duration = 0
        cookie_name     = ""
        enabled         = false
        type            = "source_ip"
    }

    health_check {
        enabled             = true
        healthy_threshold   = 3
        interval            = 30
        matcher             = "200-399"
        path                = "/actuator/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 6
        unhealthy_threshold = 3
    }
}

# terget group 에 terget 설정 
#resource "aws_lb_target_group_attachment" "nlb_tg_front_attach_443" {
#  target_group_arn = aws_lb_target_group.nlb_tg_front_443.arn
#  target_id        = aws_lb_listener.lis_alb_front.arn  
#  port             = 80
#}

## front network loadbalancer 의 listener 생성  port 80 
resource "aws_lb_listener" "lis_nlb_front_80" {
    
    load_balancer_arn   = aws_lb.network_lb.arn
    port                = 80
    protocol            = "TCP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.nlb_tg_front_80.arn
    }

}

## front network loadbalancer 의 listener 생성  port 443
resource "aws_lb_listener" "lis_nlb_front_443" {
    
    load_balancer_arn   = aws_lb.network_lb.arn
    port                = 443
    protocol            = "TCP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.nlb_tg_front_443.arn
    }

}
