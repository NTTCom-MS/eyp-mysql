class mysql::backup::xtrabackup::install(
                                          $srcdir = '/usr/local/src',
                                          $version = '2.4.4',
                                          $ensure = 'installed',
                                        ) inherits mysql::params{
  #
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  include ::mysql::perconarepo

  if($version == undef)
  {
    $version_release=''
  }
  else
  {
    if($version =~ /^([0-9])\.([0-9])/)
    {
      $version_release="${1}${2}"
    }
    else {
      fail('invalid version')
    }
  }

  # exec { 'install xtrabackup package':
  #   command => "yum install -y ${srcdir}/xtrabackup.${mysql::params::package_provider}",
  #   unless  => "rpm -qi ${mysql::params::percona_xtrabackup_package_name[$version]}"
  # }

  if($mysql::params::include_epel)
  {
    include ::epel

    Class['::epel'] {
      before => Package[$mysql::params::percona_xtrabackup_package_name[$version_release]],
    }
  }

  package { $mysql::params::percona_xtrabackup_package_name[$version_release]:
    ensure  => $mysql::package_ensure,
    require => Class['::mysql::perconarepo']
  }

}
