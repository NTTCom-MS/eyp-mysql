define mysql::community::config (
                                  $instance_name     = $name,
                                  $add_default_mycnf = false,
                                ) {

  if($add_default_mycnf)
  {
    mysql::mycnf { $instance_name:
      require => Class['::mysql'],
    }

    mysql::mycnf::mysqld{ $instance_name:
      
    }
  }
}
