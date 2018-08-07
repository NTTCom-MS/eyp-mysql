mysql::community::instance { 'test':
  port              => '3308',
  password          => 'password',
  add_default_mycnf => true,
  default_instance  => true,
}

->

mysql::backup::xtrabackup { 'test':
  destination => '/backup',
}
