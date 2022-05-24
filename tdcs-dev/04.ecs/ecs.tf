#aws 내의 현 파티션 
data "aws_partition" "current" {}

# ecs cluster 정의 
resource "aws_ecs_cluster" "tdcs_ecs_cluster" {
  name = "${local.project_id}-${local.env}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = { 
    "Name"          = "${local.project_id}-${local.env}-ecs-cluster",
    "environment"   = "${local.env}"
    "servicetitle"  = "${local.project_id}"
  }
}


# launch template 정의 
resource "aws_launch_template" "tdcs_ecs_launch_template" {
  name = "${local.project_id}-${local.env}-ecs-auto-scaling"
  description = "${local.project_id}-${local.env}-ecs-auto-scaling"
  image_id = "ami-0ef7a2936ae1e00cc"

  instance_type = "t3.large"
  user_data = base64encode(file("./ecs.sh"))

  iam_instance_profile {
    arn = aws_iam_instance_profile.tdcs_role_ecs_instance.arn
  }

  monitoring { 
    enabled = true 
  }
  
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.tdcs_sg_ecs]

  tags = { 
    "Name"          = "${local.project_id}-${local.env}-ecs-auto-scaling"
    "environment"   = "${local.env}"
    "servicetitle"  = "${local.project_id}"
  }
}

# ecs 에서 사용할 autoscaling group 정의 
resource "aws_autoscaling_group" "tdcs-ecs-asg" {
    desired_capacity          = 3
    health_check_grace_period = 300
    health_check_type         = "EC2"
    max_size                  = 3
    min_size                  = 3
    name                      = "asg-${aws_ecs_cluster.tdcs_ecs_cluster.name}"
    vpc_zone_identifier       = [data.terraform_remote_state.vpc.outputs.tdcs_dup_backend_subnet_ids[0], data.terraform_remote_state.vpc.outputs.tdcs_dup_backend_subnet_ids[1]]
    metrics_granularity       = "1Minute"
    wait_for_capacity_timeout = "10m"

    #launch_configuration = aws_launch_configuration.tdcs_ecs_instance.name

    launch_template {
      id      = aws_launch_template.tdcs_ecs_launch_template.id
      version = aws_launch_template.tdcs_ecs_launch_template.latest_version
    }

    tag {
        key   = "Name"
        value = "${local.project_id}-${local.env}-ec2-ecs-instance"
        propagate_at_launch = true
    }
    tag {
        key   = "environment"
        value = "dev"
        propagate_at_launch = true
    }
    tag {
        key   = "servicetitle"
        value = "${local.project_id}"
        propagate_at_launch = true
    }
    tag {
        key   = "personalinformation"
        value = "no"
        propagate_at_launch = true
    }
    tag {
        key   = "Cluster"
        value = aws_ecs_cluster.tdcs_ecs_cluster.name
        propagate_at_launch = true
    }
    tag {
        key   = "group"
        value = "${local.project_id}"
        propagate_at_launch = true
    }
    depends_on = [
      aws_launch_template.tdcs_ecs_launch_template, aws_ecs_cluster.tdcs_ecs_cluster
    ]
}



/*
resource "aws_ecs_cluster_capacity_providers" "tdcs_ecs_capacity_providers" {
  cluster_name = aws_ecs_cluster.main.name
  capacity_providers = [aws_ecs_capacity_provider.tdcs_capacity_provider.name]
  default_capacity_provider_strategy {
    base    = 1
    weight  = 100
    capacity_provider = aws_ecs_capacity_provider.tdcs_capacity_provider.name
  }
  depends_on = [aws_ecs_capacity_provider.tdcs_capacity_provider]
}

resource "aws_ecs_capacity_provider" "tdcs_capacity_provider" {
  name = "cp-tdcs-cluster-asg"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs-asg.arn
  }
  depends_on = [aws_autoscaling_group.ecs-asg]
}
*/

/*
resource "aws_launch_configuration" "tdcs_ecs_instance" {
  name = "tdcs_ecs_instance"
  ebs_optimized = true
  enable_monitoring = true

  image_id = "ami-0ef7a2936ae1e00cc"
  instance_type = "t3.large"
  security_groups = [aws_security_group.tdcs_sg_ecs_insance.id]
  iam_instance_profile = aws_iam_instance_profile.tdcs_role_ecs_instance.arn

  user_data = base64encode(file("./ecs.sh"))

  root_block_device {
	  encrypted           = true
	  volume_size         = 10
	  volume_type         = "gp2"
  }
}
*/