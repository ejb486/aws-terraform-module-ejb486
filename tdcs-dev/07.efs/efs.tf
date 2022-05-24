# EFS applog용
resource "aws_efs_file_system" "tdcs_efs_applog" {
    encrypted = true
    performance_mode = "generalPurpose"
  
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  
    tags = {
	    Name = "${local.project_id}-${local.env}-an2-efs-applog"
        "creator" = "P092913",
        "operator1" = "P092913",
        "operator2" = "P069329"
    }
}

# Mount Target
resource "aws_efs_mount_target" "tdcs_efs_applog_target" {
    count = length(local.aws_azs)
    file_system_id  = aws_efs_file_system.tdcs_efs_applog.id
    subnet_id       = element(data.terraform_remote_state.vpc.outputs.tdcs_dup_backend_subnet_ids, count.index)
    security_groups = [data.terraform_remote_state.sg.outputs.tdcs_sg_efs]
}

resource "aws_efs_backup_policy" "tdcs_efs_applog_backup" {
  file_system_id = aws_efs_file_system.tdcs_efs_applog.id

  backup_policy {
    status = "DISABLED"
  }
}

# Access Point
resource "aws_efs_access_point" "tdcs_efs_applog" {
  file_system_id = aws_efs_file_system.tdcs_efs_applog.id
  
  root_directory {
    path = "/tdcs"
  }
  
  tags = {
	  Name = "tdcs"
  }
}