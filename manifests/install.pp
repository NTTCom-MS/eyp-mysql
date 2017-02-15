class mysql::install inherits mysql {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
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
    owner   => 'mysql',
    group   => 'mysql',
    mode    => '0750',
  }

}
