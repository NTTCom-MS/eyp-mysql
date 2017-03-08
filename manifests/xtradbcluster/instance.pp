define mysql::xtradbcluster::instance (
                                    $password,
                                    $serverid,
                                    $cluster_list,
                                    $sst_username,
                                    $sst_password,
                                    $sst_method         = 'xtrabackup-v2',
                                    $port               = '3306',
                                    $instance_name      = $name,
                                    $cluster_name       = $name,
                                    $add_default_mycnf  = true,
                                    $instancedir        = "/var/mysql/${name}",
                                    $datadir            = "/var/mysql/${name}/datadir",
                                    $relaylogdir        = "/var/mysql/${name}/relaylog",
                                    $binlogdir          = "/var/mysql/${name}/binlogs",
                                    $logdir             = "/var/log/mysql/${name}",
                                    $default_instance   = false,
                                    $node_address       = $::ipaddress,
                                    $bootstrap          = false,
                                    $gmcast_listen_addr = 'tcp://0.0.0.0:4567',
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

  #client a /etc/mysql/instance_name/my.cnf
  mysql::mycnf::client { $instance_name:
    default     => false,
    client_name => '',
    password    => $password,
    socket      => "${datadir}/mysqld.sock",
  }

  mysql::mycnf::client { "$instance_name global config":
    default       => false,
    client_name   => $instance_name,
    instance_name => 'global',
    password      => $password,
    socket        => "${datadir}/mysqld.sock",
  }

  mysql::xtradbcluster::install { $instance_name:
    datadir     => $datadir,
    relaylogdir => $relaylogdir,
    logdir      => $logdir,
    binlogdir   => $binlogdir,
  }

  ->

  mysql::xtradbcluster::config { $instance_name:
    port                    => $port,
    add_default_mycnf       => $add_default_mycnf,
    datadir                 => $datadir,
    relaylogdir             => $relaylogdir,
    logdir                  => $logdir,
    binlogdir               => $binlogdir,
    cluster_name            => $cluster_name,
    serverid                => $serverid,
    wsrep_node_address      => $node_address,
    wsrep_cluster_address   => $cluster_list,
    wsrep_sst_auth_username => $sst_username,
    wsrep_sst_auth_password => $sst_password,
    wsrep_sst_method        => $sst_method,
    gmcast_listen_addr      => $gmcast_listen_addr,
    require                 => Class['::mysql'],
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

  if($sst_username!=undef)
  {
    exec { "sst localhost ${instance_name}":
      command => "echo \"GRANT PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '${sst_username}'@'localhost' identified by '${sst_password}';\" | mysql -S ${datadir}/mysqld.sock  -p$(tail -n1 ${instancedir}/.mypass) --connect-expired-password && echo ${password} > ${instancedir}/.mypass",
      require => [ Exec["reset password ${instance_name}"], Mysql::Xtradbcluster::Service[$instance_name] ],
      unless  => "echo \"select concat(user,'@',host) from mysql.user where host='localhost' and user='${sst_username}' and authentication_string=password('${sst_password}');\" | mysql -NB -S /var/mysql/${instance_name}/datadir/mysqld.sock -p${password} | grep ${sst_username}",
    }

    exec { "sst any ${instance_name}":
      command => "echo \"GRANT PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '${sst_username}'@'%' identified by '${sst_password}';\" | mysql -S ${datadir}/mysqld.sock  -p$(tail -n1 ${instancedir}/.mypass) --connect-expired-password && echo ${password} > ${instancedir}/.mypass",
      require => [ Exec["reset password ${instance_name}"], Mysql::Xtradbcluster::Service[$instance_name] ],
      unless  => "echo \"select concat(user,'@',host) from mysql.user where host='%' and user='${sst_username}' and authentication_string=password('${sst_password}');\" | mysql -NB -S /var/mysql/${instance_name}/datadir/mysqld.sock -p${password} | grep ${sst_username}",
    }
  }

  file { "/etc/mysql/${instance_name}/puppet_options":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/xtradbcluster/puppet_options.erb"),
    require => Mysql::Xtradbcluster::Config[$instance_name],
    notify  => Mysql::Xtradbcluster::Service[$instance_name],
  }

  # we are just deploying a template, this file is not really managed
  file { "/etc/mysql/${instance_name}/options":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "MYSQLD_OPTIONS=\"\"\n",
    replace => false,
    require => Mysql::Xtradbcluster::Config[$instance_name],
  }

}
