class mysql::perconarepo(
                          $srcdir         = '/usr/local/src',
                          $package_ensure = 'installed',
                        ) inherits mysql::params {
  #
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  $percona_gpg_path='/etc/pki/rpm-gpg/RPM-GPG-KEY-Percona'

  file { $percona_gpg_path:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => file('percona/GPG-key-percona'),
  }

  exec { 'import-percona-gpg':
    command => "rpm --import ${percona_gpg_path}",
    path    => ['/bin', '/usr/bin'],
    unless  => "rpm -q gpg-pubkey-$(gpg --throw-keyids ${percona_gpg_path} | grep pub | cut -c 12-19 | tr '[A-Z]' '[a-z]')",
    require => File[$percona_gpg_path],
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
    require  => Exec[['wget perconarepo','import-percona-gpg']],
    notify   => Exec['perconarepo install update'],
  }

  exec { 'perconarepo install update':
    command     => $mysql::params::repo_update_command,
    refreshonly => true,
    require     => Package[$mysql::params::perconarepo_reponame],
  }

}
