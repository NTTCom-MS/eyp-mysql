# https://www.percona.com/doc/percona-xtradb-cluster/5.7/install/apt.html#apt
# lsbdistcodename
class mysql::xtradbcluster(
                            $version       = '5.7',
                          ) inherits mysql::params {
  #
  include ::mysql

  include ::mysql::perconarepo

  include ::mysql::backup::xtrabackup::install

  package { $::mysql::percona_xtradbcluster_package_name[$version]:
    ensure  => $mysql::package_ensure,
    require => Class[ [ '::mysql::perconarepo', '::mysql::backup::xtrabackup::install' ] ],
    before  => Service[$mysql::params::servicename],
  }
}
