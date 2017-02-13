# notes:
# tmp_table_size=max_heap_table_size
define mysql::mycnf::mysqld (
                              $instance_name                   = $name,
                              $skip_external_locking           = $mysql::params::skip_external_locking_default,
                              $tmpdir                          = $mysql::params::tmpdir_default,
                              $datadir                         = "/var/mysql/${name}",
                              $default_storage_engine          = 'InnoDB',
                              $ignoreclientcharset             = true,
                              $charset                         = 'utf8',
                              $readonly                        = false,
                              $key_buffer_size                 = $mysql::params::key_buffer_size_default,
                              $sysdate_is_now                  = true,
                              $max_allowed_packet              = '16M',
                              $max_connect_errors              = '1000000',
                              $nameresolve                     = false,
                              $myisam_recover                  = [ 'FORCE', 'BACKUP' ],
                              $innodb                          = 'FORCE',
                              $binlogdir                       = $mysql::params::binlogdir_default,
                              $expirelogsdays                  = '5',
                              $binlog_format                   = 'MIXED',
                              $sync_binlog                     = true,
                              $serverid                        = '1',
                              $max_binlog_size                 = '1073741824',
                              $log_bin_trust_function_creators = false,
                              $slave                           = false,
                              $relaylogdir                     = '/var/mysql/binlogs',
                              $max_relay_log_size              = '0',
                              $replicate_ignore_db             = [],
                              $max_heap_table_size             = '32M',
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
                              $tmp_table_size = '32M',
                            ) {
  if($instance_name=='global')
  {
    $mycnf_path='/etc/mysql/my.cnf'
  }
  else
  {
    $mycnf_path="/etc/mysql/${instance_name}/my.cnf"
  }

  concat::fragment{ "/etc/mysql/${instance_name}/my.cnf header mysqld":
    target  => "/etc/mysql/${instance_name}/my.cnf",
    order   => '100',
    content => "[mysqld]\n\n",
  }

  concat::fragment{ "/etc/mysql/${instance_name}/my.cnf mysqld general":
    target  => "/etc/mysql/${instance_name}/my.cnf",
    order   => '101',
    content => template("${module_name}/mycnf/mysqld/01_general.erb"),
  }

  concat::fragment{ "/etc/mysql/${instance_name}/my.cnf mysqld charset":
    target  => "/etc/mysql/${instance_name}/my.cnf",
    order   => '102',
    content => template("${module_name}/mycnf/mysqld/02_charset.erb"),
  }

  concat::fragment{ "/etc/mysql/${instance_name}/my.cnf mysqld RW status":
    target  => "/etc/mysql/${instance_name}/my.cnf",
    order   => '103',
    content => template("${module_name}/mycnf/mysqld/03_rw.erb"),
  }

  concat::fragment{ "/etc/mysql/${instance_name}/my.cnf mysqld myisam":
    target  => "/etc/mysql/${instance_name}/my.cnf",
    order   => '104',
    content => template("${module_name}/mycnf/mysqld/04_myisam.erb"),
  }

  concat::fragment{ "/etc/mysql/${instance_name}/my.cnf mysqld safety":
    target  => "/etc/mysql/${instance_name}/my.cnf",
    order   => '105',
    content => template("${module_name}/mycnf/mysqld/05_safety.erb"),
  }

  concat::fragment{ "/etc/mysql/${instance_name}/my.cnf mysqld data storage":
    target  => "/etc/mysql/${instance_name}/my.cnf",
    order   => '106',
    content => template("${module_name}/mycnf/mysqld/06_data_storage.erb"),
  }

  concat::fragment{ "/etc/mysql/${instance_name}/my.cnf mysqld binlogs":
    target  => "/etc/mysql/${instance_name}/my.cnf",
    order   => '107',
    content => template("${module_name}/mycnf/mysqld/07_binlogs.erb"),
  }
}
