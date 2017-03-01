# https://www.percona.com/doc/percona-xtradb-cluster/5.7/install/apt.html#apt
# lsbdistcodename
class mysql::xtradbcluster(
                            $version       = '5.7',
                          ) inherits mysql::params {
  #
  include ::mysql::perconarepo

  package { $::mysql::percona_xtradbcluster_package_name:
    ensure => $mysql::package_ensure,
    require => Class['::mysql::perconarepo'],
  }
}
