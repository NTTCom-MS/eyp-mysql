define mysql::community::install(
                                  $instance_name = $name,
                                  $datadir       = "/var/mysql/${name}",
                                  $relaylogdir   = "/var/mysql/${name}/binlogs",
                                  $logdir        = "/var/log/mysql/${name}",
                                ) {
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  exec { "mkdir datadir ${instance_name}":
    command => "mkdir -p ${datadir}",
    creates => $datadir,
  }

  exec { "mkdir relaylogdir ${instance_name}":
    command => "mkdir -p ${relaylogdir}",
    creates => $relaylogdir,
  }

  exec { "mkdir logdir ${instance_name}":
    command => "mkdir -p ${logdir}",
    creates => $logdir,
  }
}
