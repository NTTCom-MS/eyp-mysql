class mysql::config inherits mysql {

  if($mysql::add_default_global_mycnf)
  {
    mysql::mycnf { 'global':
    }
  }

  if($mysql::params::systemd)
  {
    
  }

}
