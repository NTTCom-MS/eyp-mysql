define mysql::community::config (
                                  $instance_name = $name,
                                ) {

  if($mysql::params::systemd)
  {
    systemd::service { $instance_name:
      execstart => "--defaults-file ",
    }
  }
}
