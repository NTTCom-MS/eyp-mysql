class mysql::perconarepo() inherits mysql::params {
  #
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  include ::mysql

  exec { "mysql perconarepo srcdir ${mysql::srcdir}":
    command => "mkdir -p ${mysql::srcdir}",
    creates => $mysql::srcdir,
    require => Class['::mysql'],
  }

  exec { 'perconarepo cluster which wget':
    command => 'which wget',
    unless  => 'which wget',
    require => Exec["mysql perconarepo srcdir ${mysql::srcdir}"],
  }

  exec { 'wget perconarepo':
    command => "wget ${mysql::params::perconarepo_repo} -O ${mysql::srcdir}/repo_perconarepo.${mysql::params::package_provider}",
    creates => "${mysql::srcdir}/repo_perconarepo.${mysql::params::package_provider}",
    require => Exec['perconarepo cluster which wget'],
  }

  package { $mysql::params::perconarepo_reponame:
    ensure   => $mysql::package_ensure,
    provider => $mysql::params::package_provider,
    source   => "${mysql::srcdir}/repo_perconarepo.${mysql::params::package_provider}",
    require  => Exec['wget perconarepo'],
    notify   => Exec['perconarepo install update'],
  }

  exec { 'perconarepo install update':
    command     => $mysql::params::repo_update_command,
    refreshonly => true,
    require     => Package[$mysql::params::perconarepo_reponame],
  }

}
