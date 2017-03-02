define mysql::xtradbcluster::install(
                                  $instance_name = $name,
                                  $instancedir   = "/var/mysql/${name}",
                                  $datadir       = "/var/mysql/${name}/datadir",
                                  $relaylogdir   = "/var/mysql/${name}/binlogs",
                                  $logdir        = "/var/log/mysql/${name}",
                                ) {
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  exec { "mkdir instancedir ${instance_name}":
    command => "mkdir -p ${instancedir}",
    creates => $instancedir,
  }

  file { $instancedir:
    ensure  => 'directory',
    owner   => 'mysql',
    group   => 'mysql',
    mode    => '0750',
    require => Exec["mkdir datadir ${instance_name}"],
  }

  exec { "mkdir datadir ${instance_name}":
    command => "mkdir -p ${datadir}",
    creates => $datadir,
  }

  file { $datadir:
    ensure  => 'directory',
    owner   => 'mysql',
    group   => 'mysql',
    mode    => '0750',
    require => Exec["mkdir datadir ${instance_name}"],
  }

  exec { "mkdir relaylogdir ${instance_name}":
    command => "mkdir -p ${relaylogdir}",
    creates => $relaylogdir,
  }

  file { $relaylogdir:
    ensure  => 'directory',
    owner   => 'mysql',
    group   => 'mysql',
    mode    => '0750',
    require => Exec["mkdir relaylogdir ${instance_name}"],
  }

  exec { "mkdir logdir ${instance_name}":
    command => "mkdir -p ${logdir}",
    creates => $logdir,
  }

  file { $logdir:
    ensure  => 'directory',
    owner   => 'mysql',
    group   => 'mysql',
    mode    => '0750',
    require => Exec["mkdir logdir ${instance_name}"],
  }

  #mysql_install_db --defaults-file=/etc/mysql/my.cnf  --random-password-file=/var/mysql/test/.mypass --datadir=/var/mysql/test/datadir/ --basedir=/usr
  exec { "mysql_install_db ${instance_name}":
    command => "bash -c 'mysql_install_db --defaults-file=/etc/mysql/my.cnf --random-password-file=$(dirname ${datadir})/.mypass --datadir=${datadir} --basedir=/usr'",
    unless  => "bash -c 'test -f $(dirname ${datadir})/.mypass'",
    user    => 'mysql',
    require => File[ [ $logdir, $relaylogdir, $datadir, $instancedir ] ],
  }

}
