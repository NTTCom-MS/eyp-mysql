class mysql::perconarepo(
                          $srcdir         = '/usr/local/src',
                          $package_ensure = 'installed',
                        ) inherits mysql::params {
  #
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  exec { "mysql perconarepo srcdir ${srcdir}":
    command => "mkdir -p ${srcdir}",
    creates => $srcdir,
  }

  exec { 'perconarepo which wget':
    command => 'which wget',
    unless  => 'which wget',
    require => Exec["mysql perconarepo srcdir ${srcdir}"],
  }

  exec { 'wget perconarepo':
    command => "wget ${mysql::params::perconarepo_repo} -O ${srcdir}/repo_perconarepo.${mysql::params::package_provider}",
    creates => "${srcdir}/repo_perconarepo.${mysql::params::package_provider}",
    require => Exec['perconarepo which wget'],
  }

  package { $mysql::params::perconarepo_reponame:
    ensure   => $package_ensure,
    provider => $mysql::params::package_provider,
    source   => "${srcdir}/repo_perconarepo.${mysql::params::package_provider}",
    require  => Exec['wget perconarepo'],
    notify   => Exec['perconarepo install update'],
  }

  exec { 'perconarepo install update':
    command     => $mysql::params::repo_update_command,
    refreshonly => true,
    require     => Package[$mysql::params::perconarepo_reponame],
  }

}
