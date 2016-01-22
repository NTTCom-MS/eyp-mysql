# == Class: mysql
#
# Full description of class mysql here.
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class mysql (
              $rootpw,
              $debianpw,
            ) inherits params{

  if defined(Class['ntteam'])
  {
    ntteam::tag{ 'mysql': }
  }

  class { 'mysql::mariadb':
    rootpw   => $rootpw,
    debianpw => $debianpw,
  }
}
