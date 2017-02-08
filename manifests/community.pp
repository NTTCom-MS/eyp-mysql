define mysql::community (
                          $password,
                          $instance_name     = $name,
                          $version           = '5.7',
                          $add_default_mycnf = false,
                        ) {
  include ::mysql

  mysql::community::install { $instance_name:
    version  => $version,
    password => $password,
  }

  if($add_default_mycnf)
  {
    mysql::mycnf { $instance_name:
      require => Class['::mysql'],
    }
  }

}
