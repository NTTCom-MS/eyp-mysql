class mysql::service inherits mysql {

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
