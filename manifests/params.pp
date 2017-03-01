class mysql::params {

  $mysql_username = 'mysql'

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
                                        '' => 'percona-xtrabackup',
                                        '24' => 'percona-xtrabackup-24',
                                        '20' => 'percona-xtrabackup-20',
                                      }
  $percona_xtradbcluster_package_name = {
                                          '5.6' => [ 'percona-xtradb-cluster-server-5.6', 'percona-xtradb-cluster-client-5.6' ],
                                          '5.7' => [ 'percona-xtradb-cluster-server-5.7', 'percona-xtradb-cluster-client-5.7' ],
                                        }
  $perconarepo_reponame = 'percona-release'

  case $::osfamily
  {
    'redhat':
    {
      $mysql_username_uid = '27'
      $mysql_username_gid = '27'

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
          $systemd=false

          $mysql_repo = {
                          '5.7' => 'http://dev.mysql.com/get/mysql57-community-release-el5-7.noarch.rpm',
                        }
        }
        /^6.*$/:
        {
          $systemd=false

          $mysql_repo = {
                          '5.7' => 'http://dev.mysql.com/get/mysql57-community-release-el6-9.noarch.rpm',
                        }
        }
        /^7.*$/:
        {
          $systemd=true
          $mysql_repo = {
                          '5.7' => 'http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm',
                        }
        }
        default: { fail("Unsupported RHEL/CentOS version! - ${::operatingsystemrelease}")  }
      }
    }
    'Debian':
    {
      $mysql_username_uid = '113'
      $mysql_username_gid = '119'

      $servicename='mysql'

      $repo_update_command='apt-get update'

      $perconatoolkit_wgetcmd='bash -c \'echo https://www.percona.com$(curl https://www.percona.com/downloads/percona-toolkit/ 2>&1 | grep -Eo \'href="[^"]*deb"\' | cut -f 2 -d\")\''

      $package_provider='dpkg'

      $mysql_repo_name = {
                            '5.7' => 'mysql-apt-config',
                        }
      $perconarepo_repo = "https://repo.percona.com/apt/percona-release_0.1-4.${::lsbdistcodename}_all.deb"

      case $::operatingsystem
      {
        'Ubuntu':
        {

          $mysql_repo = {
                          '5.7' => 'http://dev.mysql.com/get/mysql-apt-config_0.8.0-1_all.deb',
                        }
          case $::operatingsystemrelease
          {
            /^14.*$/:
            {
              $systemd=false
            }
            /^16.*$/:
            {
              $systemd=true
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
