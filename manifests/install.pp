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
    case $mysql::flavor
    {
      'community':
      {
        exec { "mysql config srcdir ${mysql::srcdir}":
          command => "mkdir -p ${mysql::srcdir}",
          creates => $mysql::srcdir,
        }

        exec { "download ${mysql::srcdir} repo community mysql":
          command => "wget ${mysql::params::mysql_repo[$mysql::version]} -O ${mysql::srcdir}/repomysql.${mysql::params::package_provider}",
          creates => "${mysql::srcdir}/repomysql.${mysql::params::package_provider}",
          require => Exec["mysql config srcdir ${mysql::srcdir}"],
        }

        package { $mysql::params::mysql_repo_name[$mysql::version]:
          ensure   => $mysql::package_ensure,
          provider => $mysql::params::package_provider,
          source   => "${mysql::srcdir}/repomysql.${mysql::params::package_provider}",
          require  => Exec["download ${mysql::srcdir} repo community mysql"],
        }

        case $::osfamily
        {
          'Debian':
          {
            # debian set mysql ver:
            # echo "mysql-apt-config mysql-apt-config/select-server select mysql-5.6" | debconf-set-selections
            exec { "debian set mysql ${mysql::version}":
              command => "bash -c 'echo \"mysql-apt-config mysql-apt-config/select-server select mysql-${mysql::version}\" | debconf-set-selections'",
              unless  => "bash -c 'debconf-get-selections | grep \"mysql-apt-config/select-server\" | grep \"mysql-${mysql::version}\"'",
            }
          }
          default: {}
        }
      }
      default:
      {
        fail('unsuported MySQL flavor')
      }
    }
  }

}
