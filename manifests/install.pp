class mysql::install inherits mysql {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  # ubnutu 16
  # id mysql
  # uid=113(mysql) gid=119(mysql) groups=119(mysql)
  group { $mysql::mysql_username:
    ensure => 'present',
    gid    => $mysql::mysql_username_gid,
  }

  user { $mysql::mysql_username:
    ensure  => 'present',
    uid     => $mysql::mysql_username_uid,
    gid     => $mysql::mysql_username_gid,
    require => Group[$mysql::mysql_username],
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
    owner   => $mysql::mysql_username,
    group   => $mysql::mysql_username,
    mode    => '0755',
    require => User[$mysql::mysql_username],
  }

}
