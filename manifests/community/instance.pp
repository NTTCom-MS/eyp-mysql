define mysql::community::instance (
                                    $password,
                                    $instance_name     = $name,
                                    $add_default_mycnf = false,
                                    $instancedir       = "/var/mysql/${name}",
                                    $datadir           = "/var/mysql/${name}/datadir",
                                    $relaylogdir       = "/var/mysql/${name}/binlogs",
                                    $logdir            = "/var/log/mysql/${name}",
                                  ) {
  include ::mysql

  mysql::community::install { $instance_name:
    datadir     => $datadir,
    relaylogdir => $relaylogdir,
    logdir      => $logdir,
  }

  ->

  mysql::community::config { $instance_name:
    add_default_mycnf => $add_default_mycnf,
    datadir           => $datadir,
    relaylogdir       => $relaylogdir,
    logdir            => $logdir,
    require           => Class['::mysql'],
  }

  ~>

  mysql::community::service { $instance_name:
  }
}
