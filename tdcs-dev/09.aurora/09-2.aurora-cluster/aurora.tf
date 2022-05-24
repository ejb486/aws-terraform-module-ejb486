resource "aws_db_subnet_group" "tdcs_subnet_aurora" {
    name        = "subnetgroup-rds-${local.project_id}-${local.env}-1"
    description = "subnetgroup-rds-${local.project_id}-${local.env}-1"
    subnet_ids = [data.terraform_remote_state.vpc.outputs.tdcs_private_backend_subnet_ids[0], data.terraform_remote_state.vpc.outputs.tdcs_private_backend_subnet_ids[1]]
}

################################################################################
# aurora rds cluster & clustr instance 
################################################################################

# cluster
resource "aws_rds_cluster" "tdcs_aurora_cluster" {
    cluster_identifier                  = "rds-${local.project_id}-${local.env}-1"
    engine                              = "aurora-mysql"
    engine_version                      = "8.0.mysql_aurora.3.01.0"
    engine_mode                         = "provisioned"

    availability_zones                  = ["ap-northeast-2a","ap-northeast-2c"]
    db_subnet_group_name                = aws_db_subnet_group.tdcs_subnet_aurora.name
    db_cluster_parameter_group_name     = data.terraform_remote_state.aurora-parameter.outputs.tdcs_aurora_cluster_param


    database_name                       = "tdcsd"
    master_username                     = "mysqladm"
    master_password                     = "Sktelecom2!"
    port                                = 3306
    backup_retention_period             = 14
    #backtrack_window = 0

    copy_tags_to_snapshot               = true
    deletion_protection                 = true
    skip_final_snapshot                 = true
    storage_encrypted                   = true

    preferred_backup_window             = "18:30-19:00"
    preferred_maintenance_window        = "fri:22:00-fri:22:30"
    iam_database_authentication_enabled = false

    vpc_security_group_ids              = [data.terraform_remote_state.sg.outputs.tdcs_sg_aurora]
    enabled_cloudwatch_logs_exports     = ["error", "slowquery"]
}

# master instance
resource "aws_rds_cluster_instance" "tdcs_aurora_writer" {
    identifier                          = "rds-tdcs-dev-master-1"
    cluster_identifier                  = "rds-${local.project_id}-${local.env}-1"

    instance_class                      = "db.r6g.xlarge"
    engine                              = aws_rds_cluster.tdcs_aurora_cluster.engine
    engine_version                      = aws_rds_cluster.tdcs_aurora_cluster.engine_version
    availability_zone                   = "ap-northeast-2a"
    db_parameter_group_name             = data.terraform_remote_state.aurora-parameter.outputs.tdcs_aurora_instance_param


    auto_minor_version_upgrade          = false
    performance_insights_enabled        = true
    performance_insights_retention_period = 7

    publicly_accessible                 = false
    db_subnet_group_name                = aws_db_subnet_group.tdcs_subnet_aurora.name
    monitoring_interval                 = 60
    monitoring_role_arn                 = "arn:aws:iam::875054318754:role/rds-monitoring-role"
    promotion_tier                      = 1

    preferred_maintenance_window        = "sat:22:00-sat:22:30"
}


# reader instance
resource "aws_rds_cluster_instance" "tdcs_aurora_reader" {
    identifier                          = "rds-tdcs-dev-reader-1"
    cluster_identifier                  = "rds-${local.project_id}-${local.env}-1"

    instance_class                      = "db.r6g.xlarge"
    engine                              = aws_rds_cluster.tdcs_aurora_cluster.engine
    engine_version                      = aws_rds_cluster.tdcs_aurora_cluster.engine_version
    availability_zone                   = "ap-northeast-2c"
    db_parameter_group_name             = data.terraform_remote_state.aurora-parameter.outputs.tdcs_aurora_instance_param

    auto_minor_version_upgrade          = false
    performance_insights_enabled        = true
    performance_insights_retention_period = 7

    publicly_accessible                 = false
    db_subnet_group_name                = aws_db_subnet_group.tdcs_subnet_aurora.name
    monitoring_interval                 = 60
    monitoring_role_arn                 = "arn:aws:iam::875054318754:role/rds-monitoring-role"
    promotion_tier                      = 1 

    preferred_maintenance_window        = "sun:22:00-sun:22:30"

    depends_on = [
      aws_rds_cluster_instance.tdcs_aurora_writer
    ]
}