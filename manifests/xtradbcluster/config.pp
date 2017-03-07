define mysql::xtradbcluster::config(
                                      $serverid,
                                      $wsrep_node_address      = $::ipaddress,
                                      $wsrep_cluster_address   = [],
                                      $instance_name           = $name,
                                      $cluster_name            = $name,
                                      $port                    = '3306',
                                      $add_default_mycnf       = false,
                                      $instancedir             = "/var/mysql/${name}",
                                      $datadir                 = "/var/mysql/${name}/datadir",
                                      $relaylogdir             = "/var/mysql/${name}/relaylog",
                                      $binlogdir               = "/var/mysql/${name}/binlogs",
                                      $logdir                  = "/var/log/mysql/${name}",
                                      $wsrep_sst_auth_username = 'dmlzY2EK',
                                      $wsrep_sst_auth_password = 'Y2F0YWx1bnlhCg',
                                      $wsrep_sst_method        = 'xtrabackup-v2',
                                      $gmcast_listen_addr      = 'tcp://0.0.0.0:4567',
                                    ) {

  case $mysql::pid_location
  {
    'run':
    {
      $pid_location_systemd_xtradbcluster="/var/run/xtradbcluster${instance_name}/mysqld.pid"
    }
    'datadir':
    {
      $pid_location_systemd_xtradbcluster="/var/mysql/${instance_name}/datadir/mysqld.pid"
    }
    default:
    {
      fail("unsupported mode: ${mysql::pid_location}")
    }
  }

  if($add_default_mycnf)
  {
    mysql::mycnf { $instance_name:
      require => Class['::mysql'],
    }

    mysql::mycnf::mysqld{ $instance_name:
      port                     => $port,
      datadir                  => $datadir,
      relaylogdir              => $relaylogdir,
      binlogdir                => "${binlogdir}/binlog",
      log_error                => "${logdir}/mysql-error.log",
      slow_query_log_file      => "${logdir}/mysql-slow.log",
      binlog_format            => 'ROW',
      default_storage_engine   => 'InnoDB',
      innodb_autoinc_lock_mode => '2',
      serverid                 => $serverid,
      pidfile                  => $pid_location_systemd_xtradbcluster,
    }

    mysql::mycnf::galera { $instance_name:
      wsrep_cluster_name      => $cluster_name,
      wsrep_node_address      => $wsrep_node_address,
      wsrep_cluster_address   => $wsrep_cluster_address,
      wsrep_sst_auth_username => $wsrep_sst_auth_username,
      wsrep_sst_auth_password => $wsrep_sst_auth_password,
      wsrep_sst_method        => $wsrep_sst_method,
      gmcast_listen_addr      => $gmcast_listen_addr,
    }
  }
}
