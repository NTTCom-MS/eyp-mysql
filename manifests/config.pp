# == Class: mysql
#
# === mysql::config documentation
#
class mysql::config inherits mysql {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  case $mysql::flavor
  {
    'community':
    {
      exec { "mysql config srcdir ${mysql::srcdir}":
        command => "mkdir -p ${mysql::srcdir}",
        creates => $mysql::srcdir,
      }

      exec { "download ${mysql:srcdir} community mysql":
        command => "wget ${mysql::params::mysql_repo} -O ${mysql::srcdir}/repomysql.${mysql::params::package_provider}",
        creates => "${mysql::srcdir}/repomysql.${mysql::params::package_provider}",
      }

      
    }
    default:
    {
      fail('unsuported MySQL flavor')
    }
  }

}
