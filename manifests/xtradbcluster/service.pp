define mysql::xtradbcluster::service(
                                  $instance_name         = $name,
                                  $manage_service        = true,
                                  $manage_docker_service = true,
                                  $service_ensure        = 'running',
                                  $service_enable        = true,
                                ) {
  validate_bool($manage_docker_service)
  validate_bool($manage_service)
  validate_bool($service_enable)

  validate_re($service_ensure, [ '^running$', '^stopped$' ], "Not a valid daemon status: ${service_ensure}")

  $is_docker_container_var=getvar('::eyp_docker_iscontainer')
  $is_docker_container=str2bool($is_docker_container_var)

  if( $is_docker_container==false or
      $manage_docker_service)
  {
    if($manage_service)
    {
      service { "xtradbcluster@${instance_name}":
        ensure => $service_ensure,
        enable => $service_enable,
      }
    }
  }
}
