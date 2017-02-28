class mysql::install inherits mysql {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  # ubnutu 16
  # id mysql
  # uid=113(mysql) gid=119(mysql) groups=119(mysql)
  group { $mysql::params::mysql_username:
    ensure  => 'present',
    gid     => $mysql::params::mysql_username_gid,
  }

  user { $mysql::params::mysql_username:
    ensure  => 'present',
    uid     => $mysql::params::mysql_username_uid,
    gid     => $mysql::params::mysql_username_gid,
    require => Group[$mysql::params::mysql_username],
  }

  file { '/etc/mysql':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    purge   => true,
    recurse => true,
    force   => true,
  }

  file { '/var/mysql':
    ensure  => 'directory',
    owner   => $mysql::params::mysql_username,
    group   => $mysql::params::mysql_username,
    mode    => '0750',
    require => User[$mysql::params::mysql_username],
  }

}
