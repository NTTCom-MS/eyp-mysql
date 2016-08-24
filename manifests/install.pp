# == Class: mysql
#
# === mysql::install documentation
#
class mysql::install inherits mysql {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  if($mysql::manage_package)
  {
    # package here, for example:
    #package { $mysql::params::package_name:
    #  ensure => $mysql::package_ensure,
    #}
  }

}
