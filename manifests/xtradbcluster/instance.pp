define mysql::xtradbcluster::instance (
                                    $password,
                                    $serverid,
                                    $port              = '3306',
                                    $instance_name     = $name,
                                    $cluster_name      = $name,
                                    $add_default_mycnf = true,
                                    $instancedir       = "/var/mysql/${name}",
                                    $datadir           = "/var/mysql/${name}/datadir",
                                    $relaylogdir       = "/var/mysql/${name}/binlogs",
                                    $logdir            = "/var/log/mysql/${name}",
                                    $default_instance  = false,
                                    $node_address      = $::ipaddress,
                                    $bootstrap         = false,
                                  ) {
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  include ::mysql::xtradbcluster

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
      socket        => "${datadir}/mysqld.sock",
    }
  }
  else
  {
    mysql::mycnf::client { $instance_name:
      instance_name => 'global',
      default       => false,
      password      => $password,
      socket        => "${datadir}/mysqld.sock",
    }
  }

  mysql::xtradbcluster::install { $instance_name:
    datadir     => $datadir,
    relaylogdir => $relaylogdir,
    logdir      => $logdir,
  }

  ->

  mysql::xtradbcluster::config { $instance_name:
    port               => $port,
    add_default_mycnf  => $add_default_mycnf,
    datadir            => $datadir,
    relaylogdir        => $relaylogdir,
    logdir             => $logdir,
    cluster_name       => $cluster_name,
    serverid           => $serverid,
    wsrep_node_address => $node_address,
    require            => Class['::mysql'],
  }

  ~>

  mysql::xtradbcluster::service { $instance_name:
    tag => "eypmysql_${instance_name}",
  }

  Concat <| tag == "eypmysql_${instance_name}" |>
  ->
  Mysql::Xtradbcluster::Service <| tag == "eypmysql_${instance_name}" |>

  # 5.7
  # echo "alter user root@localhost identified by 'password' password expire never;" | mysql -S /var/mysql/test/datadir/mysqld.sock  -p$(tail -n1 /var/mysql/test/.mypass) --connect-expired-password
  exec { "reset password ${instance_name}":
    command => "echo \"alter user root@localhost identified by '${password}' password expire never;\" | mysql -S ${datadir}/mysqld.sock  -p$(tail -n1 ${instancedir}/.mypass) --connect-expired-password && echo ${password} > ${instancedir}/.mypass",
    require => Mysql::Xtradbcluster::Service[$instance_name],
    unless  => "echo \"select version()\" | mysql -S /var/mysql/${instance_name}/datadir/mysqld.sock -p${password}",
  }

  file { "/etc/mysql/$instance_name/puppet_options":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/xtradbcluster/puppet_options.erb"),
    require => Mysql::Xtradbcluster::Config[$instance_name],
  }

  # we are just deploying a template, this file is not really managed
  file { "/etc/mysql/$instance_name/options":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "MYSQLD_OPTIONS=\"\"\n",
    replace => false,
    require => Mysql::Xtradbcluster::Config[$instance_name],
  }

}
