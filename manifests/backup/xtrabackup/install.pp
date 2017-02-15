class mysql::backup::xtrabackup::install(
                                          $srcdir = '/usr/local/src',
                                          $version = '2.4.4',
                                          $ensure = 'installed',
                                        ) inherits mysql::params{
  #
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  exec { 'wget xtrabackup package':
    command => "wget ${mysql::params::percona_xtrabackup_package[$version]} -O ${srcdir}/xtrabackup.${mysql::params::package_provider}",
    creates => "${srcdir}/xtrabackup.${mysql::params::package_provider}",
    notify  => Exec['install xtrabackup package'],
  }

  exec { 'install xtrabackup package':
    command => "yum install -y ${srcdir}/xtrabackup.${mysql::params::package_provider}",
    unless  => "rpm -qi ${mysql::params::percona_xtrabackup_package_name[$version]}"
  }

}
