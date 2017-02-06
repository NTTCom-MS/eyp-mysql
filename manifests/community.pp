define mysql::community (
                          $instance_name = $name,
                          $version       = '5.7',
                        ) {
  include ::mysql

  mysql::community::install { $instance_name:
    version => $version,
  }

}
