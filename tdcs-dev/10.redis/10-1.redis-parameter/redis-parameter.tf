resource "aws_elasticache_parameter_group" "tdcs_redis_param" {
    name        = "tdcs-dev-redis"
    description = "tdcs-dev-redis"
    family      = "redis6.x"
}

resource "aws_elasticache_user_group" "tdcs_redis_usergroup" {
    engine        = "REDIS"
    user_group_id = "tdcs-dev-redis-usergroup"
    user_ids      = [aws_elasticache_user.tdcs_redis_user.user_id]
}

resource "aws_elasticache_user" "tdcs_redis_user" {
    user_id       = "tdcs"
    user_name     = "default"
    access_string = "on ~* +@all"
    engine        = "REDIS"
    passwords     = ["Sktelecom123456789!"]
}