# notes:
# tmp_table_size=max_heap_table_size
define mysql::mycnf::mysqld (
                              $instance_name                   = $name,
                              $skip_external_locking           = $mysql::params::skip_external_locking_default,
                              $tmpdir                          = $mysql::params::tmpdir_default,
                              $port                            = '3306',
                              $pidfile                         = undef,
                              $datadir                         = "/var/mysql/${name}",
                              $relaylogdir                     = "/var/mysql/${name}/relaylogs",
                              $binlogdir                       = "/var/mysql/${name}/binlogs",
                              $default_storage_engine          = 'InnoDB',
                              $ignoreclientcharset             = true,
                              $charset                         = 'utf8',
                              $readonly                        = false,
                              $key_buffer_size                 = $mysql::params::key_buffer_size_default,
                              $sysdate_is_now                  = true,
                              $max_allowed_packet              = '16M',
                              $max_connect_errors              = '1000000',
                              $nameresolve                     = false,
                              $innodb                          = 'FORCE',
                              $expirelogsdays                  = '5',
                              $binlog_format                   = 'MIXED',
                              $sync_binlog                     = true,
                              $serverid                        = '1',
                              $max_binlog_size                 = '1073741824',
                              $log_bin_trust_function_creators = false,
                              $slave                           = false,
                              $max_relay_log_size              = '0',
                              $replicate_ignore_db             = [],
                              $max_heap_table_size             = '32M',
                              $tmp_table_size                  = '32M',
                              $query_cache_type                = '0',
                              $query_cache_size                = '0',
                              $query_cache_limit               = '1048576',
                              $max_connections                 = '500',
                              $max_user_connections            = '0',
                              $thread_cache_size               = '50',
                              $open_files_limit                = '65535',
                              $table_definition_cache          = '4096',
                              $table_open_cache                = '100',
                              $sort_buffer_size                = '262144',
                              $join_buffer_size                = '131072',
                              $innodb_flush_method             = 'O_DIRECT',
                              $innodb_log_files_in_group       = '2',
                              $innodb_log_file_size            = '50331648',
                              $innodb_flush_log_at_trx_commit  = '2',
                              $innodb_file_per_table           = true,
                              $innodb_buffer_pool_size         = ceiling(sprintf('%f', $::memorysize_mb)*838860),
                              $innodb_autoinc_lock_mode        = undef,
                              $log_queries_not_using_indexes   = false,
                              $slow_query_log                  = true,
                              $log_error                       = "/var/log/mysql/${name}/mysql-error.log",
                              $slow_query_log_file             = "/var/log/mysql/${name}/mysql-slow.log",
                              $sql_mode                        = undef,
                              $lower_case_table_names          = '0',
                            ) {
  if($instance_name=='global')
  {
    $mycnf_path='/etc/mysql/my.cnf'
  }
  else
  {
    $mycnf_path="/etc/mysql/${instance_name}/my.cnf"
  }

  #TODO: https://dev.mysql.com/doc/refman/5.7/en/switchable-optimizations.html

  concat::fragment{ "${mycnf_path} header mysqld":
    target  => $mycnf_path,
    order   => '100',
    content => "\n[mysqld]\n\n",
  }

  concat::fragment{ "${mycnf_path} mysqld general":
    target  => $mycnf_path,
    order   => '101',
    content => template("${module_name}/mycnf/mysqld/01_general.erb"),
  }

  concat::fragment{ "${mycnf_path} mysqld charset":
    target  => $mycnf_path,
    order   => '102',
    content => template("${module_name}/mycnf/mysqld/02_charset.erb"),
  }

  concat::fragment{ "${mycnf_path} mysqld RW status":
    target  => $mycnf_path,
    order   => '103',
    content => template("${module_name}/mycnf/mysqld/03_rw.erb"),
  }

  concat::fragment{ "${mycnf_path} mysqld myisam":
    target  => $mycnf_path,
    order   => '104',
    content => template("${module_name}/mycnf/mysqld/04_myisam.erb"),
  }

  concat::fragment{ "${mycnf_path} mysqld safety":
    target  => $mycnf_path,
    order   => '105',
    content => template("${module_name}/mycnf/mysqld/05_safety.erb"),
  }

  concat::fragment{ "${mycnf_path} mysqld data storage":
    target  => $mycnf_path,
    order   => '106',
    content => template("${module_name}/mycnf/mysqld/06_data_storage.erb"),
  }

  concat::fragment{ "${mycnf_path} mysqld binlogs":
    target  => $mycnf_path,
    order   => '107',
    content => template("${module_name}/mycnf/mysqld/07_binlogs.erb"),
  }

  concat::fragment{ "${mycnf_path} mysqld slave":
    target  => $mycnf_path,
    order   => '108',
    content => template("${module_name}/mycnf/mysqld/08_slave.erb"),
  }

  concat::fragment{ "${mycnf_path} mysqld caches and limits":
    target  => $mycnf_path,
    order   => '109',
    content => template("${module_name}/mycnf/mysqld/09_caches_limits.erb"),
  }

  concat::fragment{ "${mycnf_path} mysqld innodb":
    target  => $mycnf_path,
    order   => '110',
    content => template("${module_name}/mycnf/mysqld/10_innodb.erb"),
  }

  concat::fragment{ "${mycnf_path} mysqld logging":
    target  => $mycnf_path,
    order   => '111',
    content => template("${module_name}/mycnf/mysqld/11_logging.erb"),
  }
}
