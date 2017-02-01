class mysql::params {

  #MySQL config
  $binlogdir_default='/var/mysql/binlogs'
  $binlog_format_default='STATEMENT'
  $charset_default='utf8'
  $datadir_default='/var/mysql/datadir/'
  $ensure_default='installed'
  $expirelogsdays_default='5'
  $ignoreclientcharset_default=false
  $innodb_buffer_pool_size_default='2G'
  $innodb_log_file_size_default='128M'
  $join_buffer_size_default='131072'
  $key_buffer_size_default='32M'
  $logdir_default='/var/log/mysql/'
  $max_binlog_size_default='1073741824'
  $max_connections_default='500'
  $max_heap_table_size_default='32M'
  $max_relay_log_size_default='0'
  $max_user_connections_default='0'
  $open_files_limit_default='65535'
  $query_cache_limit_default='1048576'
  $query_cache_size_default='0'
  $readonly_default=false
  $relaylogdir_default='/var/mysql/binlogs'
  $replicate_ignore_db_default=undef
  $serverid_default='1'
  $skip_external_locking_default=false
  $slave_default=false
  $sort_buffer_size_default='2097144'
  $srcdir_default='/usr/local/src'
  $table_open_cache_default='100'
  $thread_cache_size_default='50'
  $thread_stack_default='262144'
  $tmpdir_default=undef
  $log_bin_trust_function_creators_default=undef

  #mysqldump config
  $mysqldump_quick_default=false
  $mysqldump_quote_names_default=false

  #isamchk config
  $isamchk_key_buffer_default=undef

  $mysql_community_pkgs= [ 'mysql-community-server' ]

  $percona_xtrabackup_package_name = {
                                        '2.4.4' => 'percona-xtrabackup-24',
                                        '2.0.8' => 'percona-xtrabackup-20',
                                      }

  case $::osfamily
  {
    'redhat':
    {
      $servicename='mysqld'

      $repo_update_command='/bin/true'

      $perconatoolkit_wgetcmd='bash -c \'echo https://www.percona.com$(curl https://www.percona.com/downloads/percona-toolkit/ 2>&1 | grep -Eo \'href="[^"]*rpm"\' | cut -f 2 -d\")\''

      $package_provider='rpm'

      $mysql_repo_name = {
                            '5.7' => 'mysql57-community-release',
                        }

      case $::operatingsystemrelease
      {
        /^5.*$/:
        {
          $percona_xtrabackup_package = {
                                          '2.4.4' => 'https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.4/binary/redhat/5/x86_64/percona-xtrabackup-24-2.4.4-1.el5.x86_64.rpm',
                                          '2.0.8' => 'https://www.percona.com/downloads/XtraBackup/XtraBackup-2.0.8/RPM/rhel5/x86_64/percona-xtrabackup-20-2.0.8-587.rhel5.x86_64.rpm',
                                        }

          $mysql_repo = {
                          '5.7' => 'http://dev.mysql.com/get/mysql57-community-release-el5-7.noarch.rpm',
                        }
        }
        /^6.*$/:
        {
          $percona_xtrabackup_package = {
                                          '2.4.4' => 'https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.4/binary/redhat/6/x86_64/percona-xtrabackup-24-2.4.4-1.el6.x86_64.rpm',
                                          '2.0.8' => 'https://www.percona.com/downloads/XtraBackup/XtraBackup-2.0.8/RPM/rhel6/x86_64/percona-xtrabackup-20-2.0.8-587.rhel6.x86_64.rpm',
                                        }

          $mysql_repo = {
                          '5.7' => 'http://dev.mysql.com/get/mysql57-community-release-el6-9.noarch.rpm',
                        }
        }
        /^7.*$/:
        {
          $mysql_repo = {
                          '5.7' => 'http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm',
                        }
        }
        default: { fail("Unsupported RHEL/CentOS version! - ${::operatingsystemrelease}")  }
      }
    }
    'Debian':
    {
      $servicename='mysql'

      $repo_update_command='apt-get update'

      $perconatoolkit_wgetcmd='bash -c \'echo https://www.percona.com$(curl https://www.percona.com/downloads/percona-toolkit/ 2>&1 | grep -Eo \'href="[^"]*deb"\' | cut -f 2 -d\")\''

      $package_provider='dpkg'

      $mysql_repo_name = {
                            '5.7' => 'mysql-apt-config',
                        }

      case $::operatingsystem
      {
        'Ubuntu':
        {
          case $::operatingsystemrelease
          {
            /^14.*$/:
            {
              $percona_xtrabackup_package = {
                                              '2.4.4' => 'https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.4/binary/debian/trusty/x86_64/percona-xtrabackup-24_2.4.4-1.trusty_amd64.deb',
                                              '2.0.8' => 'https://www.percona.com/downloads/XtraBackup/XtraBackup-2.0.8/deb/precise/x86_64/percona-xtrabackup-20_2.0.8-587.precise_amd64.deb',
                                            }

              $mysql_repo = {
                              '5.7' => 'http://dev.mysql.com/get/mysql-apt-config_0.8.0-1_all.deb',
                            }
            }
            default: { fail("Unsupported Ubuntu version! - ${::operatingsystemrelease}")  }
          }
        }
        'Debian': { fail('Unsupported')  }
        default: { fail('Unsupported Debian flavour!')  }
      }
    }
    default: { fail('Unsupported OS!')  }
  }
}
