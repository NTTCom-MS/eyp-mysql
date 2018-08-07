mysql::community::instance { 'test':
  port              => '3307',
  password          => 'password',
  add_default_mycnf => true,
  default_instance  => true,
}

->

mysql_database { 'et2blog':
  ensure => 'present',
}

mysql::backup::xtrabackup { 'test':

  destination => '/backup',
}
