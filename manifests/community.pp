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

  ->

  mysql::community::config { $instance_name:
    add_default_mycnf => $add_default_mycnf,
    require           => Class['::mysql'],
  }
}
