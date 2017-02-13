define mysql::community::instance (
                                    $password,
                                    $instance_name     = $name,
                                    $datadir           = "/var/mysql/${name}",
                                    $add_default_mycnf = false,
                                  ) {
  include ::mysql

  mysql::community::install { $instance_name:
  }

  ->

  mysql::community::config { $instance_name:
    add_default_mycnf => $add_default_mycnf,
    datadir           => $datadir,
    require           => Class['::mysql'],
  }

  ~>

  mysql::community::service { $instance_name:
  }
}
