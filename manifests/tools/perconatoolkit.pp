class mysql::tools::perconatoolkit(
                                    $package_ensure = 'installed',
                                  ) inherits mysql::params {
  include ::mysql::perconarepo

  package { 'percona-toolkit':
    ensure  => $package_ensure,
    require => Class['::mysql::perconarepo'],
  }
}
