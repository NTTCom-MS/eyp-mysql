#
class mysql::mysql  (
        $version='5.7',
        $datadir='/var/mysql/datadir/',
        $binlogdir='/var/mysql/binlogs',
        $relaylogdir='/var/mysql/binlogs',
        $logdir='/var/log/mysql/',
        $srcdir='/usr/local/src',
        $rootpw,
        $debianpw=undef,
        $ensure='installed',
        $slave=false,
        $readonly=false,
        $charset='utf8',
        $ignoreclientcharset=false,
        $expirelogsdays='5',
        $serverid='1'
      ) inherits mysql::params {

  validate_re($version, [ '^5.7$' ], "Not a supported version: ${version}")
  validate_re($ensure, [ '^installed$', '^latest$' ], "ensure: installed/latest (${ensure} is not supported)")

  validate_absolute_path($datadir)
  validate_absolute_path($binlogdir)
  validate_absolute_path($logdir)
  validate_absolute_path($relaylogdir)

  validate_bool($readonly)

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  ########
  # REPO #
  ########

  exec { 'wget mysql community repo':
    command => "wget ${mysql::params::mysql_repo_pkg_url[$version]} -O ${srcdir}/mysql_community_repo.${mysql::params::package_provider}",
    creates => "${srcdir}/mysql_community_repo.${mysql::params::package_provider}",
  }

  package { $mysql::params::mysql_comunity_repo_package[$version]:
    ensure   => 'installed',
    provider => $mysql::params::package_provider,
    source   => "${srcdir}/mysql_community_repo.${mysql::params::package_provider}",
    require  => Exec['wget mysql community repo'],
  }

  ###########
  # paquets #
  ###########

  package { $mysql::params::mysql_community_packages:
    ensure  => 'installed',
    require => Package[$mysql::params::mysql_comunity_repo_package[$version]],
  }


}
