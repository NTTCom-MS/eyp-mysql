class mysql::install inherits mysql {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  # if($mysql::password=='password')
  # {
  #   fail('please change default password for MySQL')
  # }

  # if($mysql::manage_package)
  # {
  #   case $mysql::flavor
  #   {
  #     'community':
  #     {
  #       #
  #     }
  #     'galera-xtradb':
  #     {
  #       fail('unimplemented')
  #     }
  #     default:
  #     {
  #       fail('unsuported MySQL flavor')
  #     }
  #   }
  # }
}
