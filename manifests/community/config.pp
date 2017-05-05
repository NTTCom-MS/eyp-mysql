define mysql::community::config (
                                  $instance_name     = $name,
                                  $port              = '3306',
                                  $add_default_mycnf = false,
                                  $instancedir       = "/var/mysql/${name}",
                                  $datadir           = "/var/mysql/${name}/datadir",
                                  $relaylogdir       = "/var/mysql/${name}/binlogs",
                                  $logdir            = "/var/log/mysql/${name}",
                                ) {

  if($add_default_mycnf)
  {
    mysql::mycnf { $instance_name:
      require => Class['::mysql'],
    }

    mysql::mycnf::mysqld{ $instance_name:
      port                => $port,
      datadir             => $datadir,
      relaylogdir         => $relaylogdir,
      log_error           => "${logdir}/mysql-error.log",
      slow_query_log_file => "${logdir}/mysql-slow.log",
    }
  }

  if(!$mysql::params::systemd)
  {
    case $mysql::pid_location
    {
      'run':
      {
        $pid_location_sysv_community="/var/run/community${instance_name}/mysqld.pid"
        #$pid_location_sysv_xtradbcluster="/var/run/xtradbcluster${instance_name}/mysqld.pid"
      }
      'datadir':
      {
        $pid_location_sysv_community="/var/mysql/${instance_name}/datadir/mysqld.pid"
        #$pid_location_sysv_xtradbcluster="/var/mysql/${instance_name}/datadir/mysqld.pid"
      }
      default:
      {
        fail("unsupported mode: ${mysql::pid_location}")
      }
    }

    initscript::service { "mysqlcommunity@${instance_name}":
      cmd            => "/usr/sbin/mysqld --defaults-file=/etc/mysql/${instance_name}/my.cnf --user=mysql --pid-file=${pid_location_sysv_community} \$PUPPET_MYSQLD_OPTIONS \$MYSQLD_OPTIONS",
      option_scripts => [ "/etc/mysql/${instance_name}/puppet_options", "/etc/mysql/${instance_name}/options" ],
    }
  }


}
