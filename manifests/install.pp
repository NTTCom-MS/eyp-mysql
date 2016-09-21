# == Class: mysql
#
# === mysql::install documentation
#
class mysql::install inherits mysql {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  if($mysql::password=='password')
  {
    fail('please change default password for MySQL')
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
          notify   => Exec['mysql install repo update'],
        }

        exec { 'mysql install repo update':
          command     => $mysql::params::repo_update_command,
          refreshonly => true,
          before      => Package[$mysql_community_pkgs],
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
              before  => Package[$mysql_community_pkgs],
            }

            # echo "mysql-community-server mysql-community-server/root-pass password $ROOT_PASSWORD" | /usr/bin/debconf-set-selections
            # echo "mysql-community-server mysql-community-server/re-root-pass password $ROOT_PASSWORD" | /usr/bin/debconf-set-selections
            # echo "mysql-community-server mysql-community-server/remove-data-dir boolean false" | /usr/bin/debconf-set-selections
            # echo "mysql-community-server mysql-community-server/data-dir note" | /usr/bin/debconf-set-selections

          }
          default: {}
        }

        # aqui paquet mysql server

        # mysql_community_pkgs
        package { $mysql_community_pkgs:
          ensure  => 'installed',
          require => Package[$mysql::params::mysql_repo_name[$mysql::version]],
        }
      }
      default:
      {
        fail('unsuported MySQL flavor')
      }
    }
  }
}
