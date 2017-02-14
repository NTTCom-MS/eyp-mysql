define mysql::community::config (
                                  $instance_name     = $name,
                                  $add_default_mycnf = false,
                                  $instancedir       = "/var/mysql/${name}",
                                  $datadir           = "/var/mysql/${name}/datadir",
                                  $relaylogdir       = "/var/mysql/${name}/binlogs",
                                  $logdir            = "/var/log/mysql/${name}",
                                ) {

  if($add_default_mycnf)
  {
    #TODO: afegir dependencies genèriques

    mysql::mycnf { $instance_name:
      require => Class['::mysql'],
    }

    mysql::mycnf::mysqld{ $instance_name:
      datadir             => $datadir,
      relaylogdir         => $relaylogdir,
      log_error           => "${logdir}/mysql-error.log",
      slow_query_log_file => "${logdir}/mysql-slow.log",
    }
  }
}
