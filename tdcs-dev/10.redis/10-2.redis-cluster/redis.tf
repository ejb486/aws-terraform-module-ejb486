resource "aws_elasticache_subnet_group" "tdcs_redis_subnets" {
    name  = "subnetgroup-redis-tdcs-dev"
    subnet_ids = [data.terraform_remote_state.vpc.outputs.tdcs_private_backend_subnet_ids[0], data.terraform_remote_state.vpc.outputs.tdcs_private_backend_subnet_ids[1]]
    description = "subnetgroup-redis-tdcs-dev"
}

resource "aws_elasticache_replication_group" "tdcs_redis_cluster" {
  replication_group_id          = "tdcs-dev-redis"
  replication_group_description = "tdcs-dev-redis"

  // Elasticache Subnet Group: 캐시 서브넷 그룹의 이름 
  subnet_group_name    = "subnetgroup-redis-tdcs-dev"
  parameter_group_name = data.terraform_remote_state.redis-parameter.outputs.tdcs_redis_parameter
  security_group_ids   = [data.terraform_remote_state.sg.outputs.tdcs_sg_ec2_redis]
  user_group_ids       = [data.terraform_remote_state.redis-parameter.outputs.tdcs_redis_usergroup]
  port                 = 6379

  // Node 유형
  node_type                     = "cache.t4g.small"
  apply_immediately             = false
  multi_az_enabled              = true

  // 암호화 설정 및 읽기 전용 replica의 자동 승격 여부
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
  automatic_failover_enabled    = true
  snapshot_retention_limit      = 1
  snapshot_window               = "23:30-00:30"

  // Default: Engine "redis" 및 Engine Version "6.x"
  engine                        = "redis" 
  engine_version                = "6.x"
  number_cache_clusters         = 2

  tags = {
      name: "tdcs-dev-redis"
  }