class mysql::config inherits mysql {

  if($mysql::add_default_global_mycnf)
  {
    mysql::mycnf { 'global':
    }
  }

  if($mysql::params::systemd)
  {
    # mysql community
    systemd::service { "mysqlcommunity@":
      description                 => 'mysql community %i',
      type                        => 'forking',
      execstart                   => "/usr/sbin/mysqld --daemonize --pid-file=/var/run/community%i/mysqld.pid --defaults-file=/etc/mysql/%i/my.cnf",
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
