#Aurora Cluster Parameter Group
resource "aws_rds_cluster_parameter_group" "tdcs_aurora_param" {
    name        = "${local.project_id}-aurora-mysql-1"
    family      = "aurora-mysql8.0"
    description = "${local.project_id}-aurora-mysql-1"

  parameter {
    apply_method = "immediate"
    name = "binlog_cache_size"
    value = "1048576"
  }  
  
  parameter {
    apply_method = "immediate"
    name = "bulk_insert_buffer_size"
    value = "67108864"
  }

  parameter {
    apply_method = "immediate"
    name = "init_connect"
    value = "set names utf8mb4, collation_connection=utf8mb4_bin"
  }

  parameter {
    apply_method = "immediate"
    name = "innodb_lock_wait_timeout"
    value = "15"
   }

  parameter {
    apply_method = "immediate"
    name = "innodb_monitor_enable"
    value = "all"
   }

  parameter {
    apply_method = "immediate"
    name = "interactive_timeout"
    value = "600"
   }

  parameter {
    apply_method = "immediate"
    name = "join_buffer_size"
    value = "1048576"
   }

  parameter {
    apply_method = "immediate"
    name = "key_buffer_size"
    value = "134217728"
   }

  parameter {
    apply_method = "immediate"
    name = "max_heap_table_size"
    value = "134217728"
   }

  parameter {
    apply_method = "immediate"
    name = "max_connections"
    value = "1024"
  }

  parameter {
    apply_method = "pending-reboot"
    name = "performance_schema"
    value = "1"
   }

  parameter {
    apply_method = "immediate"
    name = "read_buffer_size"
    value = "2097152"
   }

  parameter {
    apply_method = "immediate"
    name = "read_rnd_buffer_size"
    value = "8388608"
   }

  parameter {
    apply_method = "immediate"
    name = "slow_query_log"
    value = "1"
   }

  parameter {
    apply_method = "immediate"
    name = "sort_buffer_size"
    value = "1048576"
   }

  parameter {
    apply_method = "immediate"
    name = "tmp_table_size"
    value = "134217728"
   }

  parameter {
    apply_method = "immediate"
    name = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    apply_method = "immediate"
    name = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    apply_method = "immediate"
    name = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    apply_method = "immediate"
    name = "character_set_filesystem"
    value = "binary"
  }

  parameter {
    apply_method = "immediate"
    name = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    apply_method = "immediate"
    name = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    apply_method = "immediate"
    name = "collation_connection"
    value = "utf8mb4_bin"
  }

  parameter {
    apply_method = "immediate"
    name = "collation_server"
    value = "utf8mb4_bin"
  }

  parameter {
    apply_method = "immediate"
    name = "innodb_thread_sleep_delay"
    value = "0"
  }

  parameter {
    apply_method = "immediate"
    name = "sql_mode"
    value = "STRICT_ALL_TABLES,STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION"
  }

  parameter {
    apply_method = "immediate"
    name = "time_zone"
    value = "Asia/Seoul"
  }

    parameter {
    apply_method = "immediate"
    name = "transaction_isolation"
    value = "READ-COMMITTED"
  }

    parameter {
    apply_method = "pending-reboot"
    name = "character-set-client-handshake"
    value = "0"
  }

  parameter {
    apply_method = "pending-reboot"
    name = "ft_min_word_len"
    value = "4"
  }

  parameter {
    apply_method = "pending-reboot"
    name = "innodb_autoinc_lock_mode"
    value = "1"
  }

  parameter {
    apply_method = "pending-reboot"
    name = "innodb_file_per_table"
    value = "1"
  }

  parameter {
    apply_method = "pending-reboot"
    name = "lower_case_table_names"
    value = "1"
  }

  parameter {
    apply_method = "immediate"
    name = "table_open_cache"
    value = "10240"
   }

  parameter {
    apply_method = "immediate"
    name = "log_bin_trust_function_creators"
    value = "1"
   }

  parameter {
    apply_method = "pending-reboot"
    name = "performance_schema_consumer_events_statements_current"
    value = "1"
   }

  parameter {
    apply_method = "pending-reboot"
    name = "performance-schema-consumer-events-waits-current"
    value = "ON"
   }

  parameter {
    apply_method = "pending-reboot"
    name = "performance_schema_consumer_events_statements_history"
    value = "1"
   }

  parameter {
    apply_method = "pending-reboot"
    name = "performance_schema_consumer_events_statements_history_long"
    value = "1"
   }

  parameter {
    apply_method = "pending-reboot"
    name = "performance_schema_max_digest_length"
    value = "4096"
   }

  parameter {
    apply_method = "pending-reboot"
    name = "performance_schema_max_sql_text_length"
    value = "4096"
   }

  parameter {
    apply_method = "immediate"
    name = "max_allowed_packet"
    value = "402653184"
   }
}

#Aurora Instance Parameter Group
resource "aws_db_parameter_group" "tdcs_aurora_param" {
    name        = "${local.project_id}-aurora-mysql-1"
    family      = "aurora-mysql8.0"
    description = "${local.project_id}-aurora-mysql-1"

  parameter {
    apply_method = "immediate"
    name = "binlog_cache_size"
    value = "1048576"
  }  
  
  parameter {
    apply_method = "immediate"
    name = "bulk_insert_buffer_size"
    value = "67108864"
  }

  parameter {
    apply_method = "immediate"
    name = "init_connect"
    value = "set names utf8mb4, collation_connection=utf8mb4_bin"
  }

  parameter {
    apply_method = "immediate"
    name = "innodb_lock_wait_timeout"
    value = "15"
   }

  parameter {
    apply_method = "immediate"
    name = "innodb_monitor_enable"
    value = "all"
   }

  parameter {
    apply_method = "immediate"
    name = "interactive_timeout"
    value = "600"
   }

  parameter {
    apply_method = "immediate"
    name = "join_buffer_size"
    value = "1048576"
   }

  parameter {
    apply_method = "immediate"
    name = "key_buffer_size"
    value = "134217728"
   }

  parameter {
    apply_method = "immediate"
    name = "max_allowed_packet"
    #value = "134217728"
    #value = "268435456"
    value = "402653184"
   }

  parameter {
    apply_method = "pending-reboot"
    name = "performance_schema"
    value = "1"
   }

  parameter {
    apply_method = "immediate"
    name = "read_buffer_size"
    value = "2097152"
   }

  parameter {
    apply_method = "immediate"
    name = "read_rnd_buffer_size"
    value = "8388608"
   }

  parameter {
    apply_method = "immediate"
    name = "slow_query_log"
    value = "1"
   }

  parameter {
    apply_method = "immediate"
    name = "sort_buffer_size"
    value = "1048576"
   }

  parameter {
    apply_method = "immediate"
    name = "tmp_table_size"
    value = "134217728"
   }

  parameter {
    apply_method = "immediate"
    name = "innodb_thread_sleep_delay"
    value = "0"
   }

  parameter {
    apply_method = "immediate"
    name = "log_bin_trust_function_creators"
    value = "1"
   }

  parameter {
    apply_method = "immediate"
    name = "long_query_time"
    value = "2"
   }

  parameter {
    apply_method = "immediate"
    name = "sql_mode"
    value = "STRICT_ALL_TABLES,STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION"
   }

   parameter {
    apply_method = "immediate"
    name = "transaction_isolation"
    value = "READ-COMMITTED"
   }

   parameter {
    apply_method = "pending-reboot"
    name = "ft_min_word_len"
    value = "4"
   }

  parameter {
    apply_method = "immediate"
    name = "max_heap_table_size"
    value = "134217728"
   }

  parameter {
    apply_method = "immediate"
    name = "table_open_cache"
    value = "10240"
   }

  parameter {
    apply_method = "pending-reboot"
    name = "performance_schema_consumer_events_statements_current"
    value = "1"
   }

  parameter {
    apply_method = "pending-reboot"
    name = "performance-schema-consumer-events-waits-current"
    value = "ON"
   }

  parameter {
    apply_method = "pending-reboot"
    name = "performance_schema_consumer_events_statements_history"
    value = "1"
   }

  parameter {
    apply_method = "pending-reboot"
    name = "performance_schema_consumer_events_statements_history_long"
    value = "1"
   }

  parameter {
    apply_method = "pending-reboot"
    name = "performance_schema_max_digest_length"
    value = "4096"
   }

  parameter {
    apply_method = "pending-reboot"
    name = "performance_schema_max_sql_text_length"
    value = "4096"
   }

}