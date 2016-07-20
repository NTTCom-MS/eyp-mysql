#
class mysql (
              $rootpw,
              $debianpw,
              $mysql_type = 'community',
            ) inherits mysql::params{

  if defined(Class['ntteam'])
  {
    ntteam::tag{ 'mysql': }
  }

  if($mysql_type=='mariadb')
  {
    class { 'mysql::mariadb':
    rootpw   => $rootpw,
    debianpw => $debianpw,
    }
  }
  elsif($mysql_type=='community')
  {
    class { 'mysql::community':
    rootpw   => $rootpw,
    debianpw => $debianpw,
    }
}
}
