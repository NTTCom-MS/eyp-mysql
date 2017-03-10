class mysql::config inherits mysql {

  case $mysql::pid_location
  {
    'run':
    {
      $pid_location_systemd_community='/var/run/community%i/mysqld.pid'
      $pid_location_systemd_xtradbcluster='/var/run/xtradbcluster%i/mysqld.pid'
    }
    'datadir':
    {
      $pid_location_systemd_community='/var/mysql/%i/datadir/mysqld.pid'
      $pid_location_systemd_xtradbcluster='/var/mysql/%i/datadir/mysqld.pid'
    }
    default:
    {
      fail("unsupported mode: ${mysql::pid_location}")
    }
  }

  if($mysql::add_default_global_mycnf)
  {
    mysql::mycnf { 'global':
    }

    #ln -s /etc/mysql/my.cnf /etc/mysql/my.cnf.fallback
    file { '/etc/mysql/my.cnf.fallback':
      ensure  => 'link',
      target  => '/etc/mysql/my.cnf',
      require => Mysql::Mycnf['global'],
    }
  }

  if($mysql::params::systemd)
  {
    # mysql community
    systemd::service { 'mysqlcommunity@':
      description                 => 'mysql community %i',
      type                        => 'forking',
      execstart                   => "/usr/sbin/mysqld --defaults-file=/etc/mysql/%i/my.cnf  --daemonize --pid-file=${pid_location_systemd_community} \$PUPPET_MYSQLD_OPTIONS \$MYSQLD_OPTIONS",
      user                        => 'mysql',
      group                       => 'mysql',
      pid_file                    => $pid_location_systemd_community,
      permissions_start_only      => true,
      restart                     => 'on-failure',
      limit_nofile                => '10000',
      timeoutsec                  => '600',
      restart_prevent_exit_status => [ '1' ],
      runtime_directory           => [ 'community%i' ],
      runtime_directory_mode      => '0755',
      restart_sec                 => '1',
      environment_files           => [ '-/etc/mysql/%i/puppet_options', '-/etc/mysql/%i/options' ],
    }

    systemd::service { 'xtradbcluster@':
      description                 => 'percona xtradbcluster (galera) %i',
      type                        => 'forking',
      execstart                   => "/usr/sbin/mysqld --defaults-file=/etc/mysql/%i/my.cnf  --daemonize --pid-file=${pid_location_systemd_xtradbcluster} \$PUPPET_MYSQLD_OPTIONS \$MYSQLD_OPTIONS",
      user                        => 'mysql',
      group                       => 'mysql',
      pid_file                    => $pid_location_systemd_xtradbcluster,
      permissions_start_only      => true,
      #restart                     => 'on-failure',
      restart                     => 'no',
      limit_nofile                => '10000',
      timeoutsec                  => '600',
      restart_prevent_exit_status => [ '1' ],
      runtime_directory           => [ 'xtradbcluster%i' ],
      runtime_directory_mode      => '0755',
      restart_sec                 => '1',
      environment_files           => [ '-/etc/mysql/%i/puppet_options', '-/etc/mysql/%i/options' ],
    }
  }
}
