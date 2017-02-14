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

  # 5.7
  # echo "alter user root@localhost identified by 'password' password expire never;" | mysql -S /var/mysql/test/datadir/mysqld.sock  -p$(tail -n1 /var/mysql/test/.mypass) --connect-expired-password
  exec { "reset password ${instance_name}":
    command => "echo \"alter user root@localhost identified by '${password}' password expire never;\" | mysql -S ${datadir}/mysqld.sock  -p$(tail -n1 ${instancedir}/.mypass) --connect-expired-password",
  }

}
