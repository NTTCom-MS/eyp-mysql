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
              $type='community',
            ) inherits mysql::params{

  if defined(Class['ntteam'])
  {
    ntteam::tag{ 'mysql': }
  }

  if($type=='mariadb')
  {
    class { 'mysql::mariadb':
    rootpw   => $rootpw,
    debianpw => $debianpw,
    }
  }

  if($type=='community')
  {
    class { 'mysql::community':
    rootpw   => $rootpw,
    debianpw => $debianpw,
    }
}
}
