class mysql::config inherits mysql {

  if($mysql::add_default_global_mycnf)
  {
    mysql::mycnf { 'global':
    }

    #ln -s /etc/mysql/my.cnf /etc/mysql/my.cnf.fallback
    file { '/etc/mysql/my.cnf.fallback':
      ensure => 'link',
      target => '/etc/mysql/my.cnf',
      require => Mysql::Mycnf['global'],
    }
  }

  if($mysql::params::systemd)
  {
    # mysql community
    systemd::service { 'mysqlcommunity@':
      description                 => 'mysql community %i',
      type                        => 'forking',
      execstart                   => '/usr/sbin/mysqld --defaults-file=/etc/mysql/%i/my.cnf  --daemonize --pid-file=/var/run/community%i/mysqld.pid',
      user                        => 'mysql',
      group                       => 'mysql',
      pid_file                    => '/var/run/community%i/mysqld.pid',
      permissions_start_only      => true,
      restart                     => 'on-failure',
      limit_nofile                => '10000',
      timeoutsec                  => '600',
      restart_prevent_exit_status => [ '1' ],
      runtime_directory           => [ 'community%i' ],
      runtime_directory_mode      => '755',
      restart_sec                 => '1',
    }
  }
  else
  {
    #sys-v init script
    fail('TODO: init script sys-v')
  }
}
