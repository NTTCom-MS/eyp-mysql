define mysql::community::install(
                                  $password,
                                  $instance_name = $name,
                                  $version       = '5.7',
                                  $datadir       = "/var/mysql/${name}",
                                ) {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  include ::mysql

  exec { "mysql config srcdir ${mysql::srcdir}":
    command => "mkdir -p ${mysql::srcdir}",
    creates => $mysql::srcdir,
    require => Class['::mysql'],
  }

  exec { "download ${mysql::srcdir} repo community mysql":
    command => "wget ${mysql::params::mysql_repo[$version]} -O ${mysql::srcdir}/repomysql.${mysql::params::package_provider}",
    creates => "${mysql::srcdir}/repomysql.${mysql::params::package_provider}",
    require => Exec["mysql config srcdir ${mysql::srcdir}"],
  }

  package { $mysql::params::mysql_repo_name[$version]:
    ensure   => $mysql::package_ensure,
    provider => $mysql::params::package_provider,
    source   => "${mysql::srcdir}/repomysql.${mysql::params::package_provider}",
    require  => Exec["download ${mysql::srcdir} repo community mysql"],
    notify   => Exec['mysql install repo update'],
  }

  exec { 'mysql install repo update':
    command     => $mysql::params::repo_update_command,
    refreshonly => true,
    before      => Package[$mysql::params::mysql_community_pkgs],
  }

  case $::osfamily
  {
    'Debian':
    {
      # debian set mysql ver:
      # echo "mysql-apt-config mysql-apt-config/select-server select mysql-5.6" | debconf-set-selections
      exec { "debian set mysql ${version}":
        command => "bash -c 'echo \"mysql-apt-config mysql-apt-config/select-server select mysql-${version}\" | debconf-set-selections'",
        unless  => "bash -c 'debconf-get-selections | grep \"mysql-apt-config/select-server\" | grep \"mysql-${version}\"'",
        before  => Package[$mysql::params::mysql_community_pkgs],
      }

      # password for default instance, not used
      # echo "mysql-community-server mysql-community-server/root-pass password $ROOT_PASSWORD" | /usr/bin/debconf-set-selections
      exec { 'debian set root pass':
        command => "bash -c 'echo \"mysql-community-server mysql-community-server/root-pass password dmlzY2EgY2F0YWx1bnlhIGxsaXVyZQo\" | debconf-set-selections'",
        unless  => "bash -c 'debconf-get-selections | grep -P \"mysql-community-server[ \\t]*mysql-community-server/root-pass\" | grep \"dmlzY2EgY2F0YWx1bnlhIGxsaXVyZQo\"'",
        before  => Package[$mysql::params::mysql_community_pkgs],
      }

      # password for default instance, not used
      # echo "mysql-community-server mysql-community-server/re-root-pass password $ROOT_PASSWORD" | /usr/bin/debconf-set-selections
      exec { 'debian set re root pass':
        command => "bash -c 'echo \"mysql-community-server mysql-community-server/re-root-pass password dmlzY2EgY2F0YWx1bnlhIGxsaXVyZQo\" | debconf-set-selections'",
        unless  => "bash -c 'debconf-get-selections | grep -P \"mysql-community-server[ \\t]*mysql-community-server/re-root-pass\" | grep \"dmlzY2EgY2F0YWx1bnlhIGxsaXVyZQo\"'",
        before  => Package[$mysql::params::mysql_community_pkgs],
      }

      # echo "mysql-community-server mysql-community-server/data-dir note" | /usr/bin/debconf-set-selections
      # ???

      # echo "mysql-community-server mysql-community-server/remove-data-dir boolean false" | /usr/bin/debconf-set-selections
      exec { 'debian set remove datadir':
        command => "bash -c 'echo \"mysql-community-server mysql-community-server/remove-data-dir boolean ${mysql::remove_data_dir}\" | debconf-set-selections'",
        unless  => "bash -c 'debconf-get-selections | grep \"mysql-community-server/remove-data-dir\" | grep -P \"boolean[ \\t]*${mysql::remove_data_dir}\"'",
        before  => Package[$mysql::params::mysql_community_pkgs],
      }
    }
    default: {}
  }

  # aqui paquet mysql server

  # mysql_community_pkgs
  package { $mysql::params::mysql_community_pkgs:
    ensure  => $mysql::package_ensure,
    require => Package[$mysql::params::mysql_repo_name[$version]],
  }

  # aqui instalació datadir
}
