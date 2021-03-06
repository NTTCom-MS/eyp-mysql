# puppet2sitepp @mysqlcommunityinstances
define mysql::community::instance (
                                    $password,
                                    $port              = '3306',
                                    $instance_name     = $name,
                                    $add_default_mycnf = true,
                                    $instancedir       = "/var/mysql/${name}",
                                    $datadir           = "/var/mysql/${name}/datadir",
                                    $relaylogdir       = "/var/mysql/${name}/binlogs",
                                    $logdir            = "/var/log/mysql/${name}",
                                    $default_instance  = false,
                                  ) {
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  include ::mysql::community

  if($default_instance)
  {
    if(!$add_default_mycnf)
    {
      fail('cannot set a mysql instance as the default instance if it\'s my.cnf is managed manually')
    }

    mysql::mycnf::client { 'default_client':
      instance_name => 'global',
      default       => true,
      password      => $password,
      socket        => "${instancedir}/mysqld.sock",
    }
  }

  #client a /etc/mysql/instance_name/my.cnf
  mysql::mycnf::client { $instance_name:
    default     => false,
    client_name => '',
    password    => $password,
    socket      => "${instancedir}/mysqld.sock",
  }

  mysql::mycnf::client { "${instance_name} global config":
    default       => false,
    client_name   => $instance_name,
    instance_name => 'global',
    password      => $password,
    socket        => "${instancedir}/mysqld.sock",
  }

  mysql::community::install { $instance_name:
    datadir     => $datadir,
    relaylogdir => $relaylogdir,
    logdir      => $logdir,
  }

  -> mysql::community::config { $instance_name:
    port              => $port,
    add_default_mycnf => $add_default_mycnf,
    datadir           => $datadir,
    relaylogdir       => $relaylogdir,
    logdir            => $logdir,
    require           => Class['::mysql'],
  }

  mysql::community::service { $instance_name:
    tag => "eypmysql_${instance_name}",
  }

  Concat <| tag == "eypmysql_${instance_name}" |>
  ~> Mysql::Community::Service <| tag == "eypmysql_${instance_name}" |>

  # 5.7
  # echo "alter user root@localhost identified by 'password' password expire never;" | mysql -S /var/mysql/test/datadir/mysqld.sock  -p$(tail -n1 /var/mysql/test/.mypass) --connect-expired-password
  exec { "reset password ${instance_name}":
    command => "echo \"alter user root@localhost identified by '${password}' password expire never;\" | mysql -S ${instancedir}/mysqld.sock  -p$(tail -n1 ${instancedir}/.mypass) --connect-expired-password && echo ${password} > ${instancedir}/.mypass",
    require => [ Mysql::Community::Install[$instance_name], Mysql::Community::Service[$instance_name] ],
    unless  => "echo \"select version()\" | mysql -S ${instancedir}/mysqld.sock -p${password}",
  }

}
