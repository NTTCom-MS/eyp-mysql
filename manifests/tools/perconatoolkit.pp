class mysql::tools::perconatoolkit(
                                    $package_ensure = 'installed',
                                  ) inherits mysql::params {
  include ::mysql::perconarepo

  # nota compatibilitat
  #
  # Error Summary
  # -------------
  # Error: /Stage[main]/Mysql::Tools::Perconatoolkit/Package[percona-toolkit]/ensure: change from purged to present failed: Execution of '/usr/bin/yum -d 0 -e 0 -y install percona-toolkit' returned 1: Transaction Check Error:
  #   file /etc/my.cnf from install of Percona-Server-shared-51-5.1.73-rel14.12.625.rhel6.x86_64 conflicts with file from package mysql-community-server-5.7.20-1.el6.x86_64

  package { 'percona-toolkit':
    ensure  => $package_ensure,
    require => Class['::mysql::perconarepo'],
  }
}
