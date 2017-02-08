class mysql::config inherits mysql {

  if($mysql::add_default_global_mycnf)
  {
    mysql::mycnf { 'global':
    }
  }

  if($mysql::params::systemd)
  {
    systemd::service { "mysqlcommunity@":
      execstart => "/usr/sbin/mysqld --daemonize --pid-file=/var/run/mysqld/mysqld.pid --defaults-file /etc/mysql/%i/my.cnf",
    }
  }
}
