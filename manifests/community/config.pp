define mysql::community::config (
                                  $instance_name     = $name,
                                  $add_default_mycnf = false,
                                  $datadir           = "/var/mysql/${name}",
                                  $relaylogdir       = "/var/mysql/${name}/binlogs",
                                  $logdir            = "/var/log/mysql/${name}",
                                ) {

  if($add_default_mycnf)
  {
    mysql::mycnf { $instance_name:
      require => Class['::mysql'],
    }

    mysql::mycnf::mysqld{ $instance_name:
      datadir => $datadir,
      relaylogdir => $relaylogdir,
      log_error => $log_error,
      slow_query_log_file => $slow_query_log_file,
    }
  }
}
