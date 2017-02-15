class mysql::service inherits mysql {

  #
  validate_bool($mysql::manage_docker_service)
  validate_bool($mysql::manage_service)
  validate_bool($mysql::service_enable)

  validate_re($mysql::service_ensure, [ '^running$', '^stopped$' ], "Not a valid daemon status: ${mysql::service_ensure}")

  $is_docker_container_var=getvar('::eyp_docker_iscontainer')
  $is_docker_container=str2bool($is_docker_container_var)

  if( $is_docker_container==false or
      $mysql::manage_docker_service)
  {
    if($mysql::manage_service)
    {
      service { $mysql::params::servicename:
        ensure => $mysql::service_ensure,
        enable => $mysql::service_enable,
      }
    }
  }
}
