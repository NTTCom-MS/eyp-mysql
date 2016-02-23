class mysql::params {

  $mariadb_packages= [ 'mariadb-server-5.5', 'mariadb-client-5.5' ]
  $community_packages= [ 'mysql-server-5.6', 'mysql-client-5.6' ]

  #MySQL config
  $binlog_format_default='STATEMENT'
  $innodb_buffer_pool_size_default='2G'
  $innodb_log_file_size_default='128M'
  $join_buffer_size_default='131072'
  $key_buffer_size_default='32M'
  $max_binlog_size_default='1073741824'
  $max_connections_default='500'
  $max_heap_table_size_default='32M'
  $max_relay_log_size_default='0'
  $max_user_connections_default='0'
  $open_files_limit_default='65535'
  $query_cache_limit_default='1048576'
  $query_cache_size_default='0'
  $sort_buffer_size_default='2097144'
  $table_open_cache_default='100'
  $thread_cache_size_default='50'
  $thread_stack_default='262144'

  case $::osfamily
  {
    'redhat':
    {
      #$perconatoolkit_wgetcmd="bash -c 'curl https://www.percona.com/downloads/percona-toolkit/ 2>&1 | grep -Eo \'href="[^"]*rpm"\' | cut -f 2 -d\"'"
      $perconatoolkit_wgetcmd='bash -c \'echo https://www.percona.com$(curl https://www.percona.com/downloads/percona-toolkit/ 2>&1 | grep -Eo \'href="[^"]*rpm"\' | cut -f 2 -d\")\''

      case $::operatingsystemrelease
      {
        /^5.*$/:
        {
          $mysql_repo_pkg_url={ '5.7' => 'http://dev.mysql.com/get/mysql57-community-release-el5-7.noarch.rpm' }
          $package_provider='rpm'
          $mysql_comunity_repo_package={ '5.7' => 'mysql57-community-release'}

          $mysql_community_packages= [ 'mysql-community-client', 'mysql-community-server' ]
        }
        /^6.*$/:
        {
          $mysql_repo_pkg_url={ '5.7' => 'http://dev.mysql.com/get/mysql57-community-release-el6-7.noarch.rpm' }
          $package_provider='rpm'
          $mysql_comunity_repo_package={ '5.7' => 'mysql57-community-release'}

          $mysql_community_packages= [ 'mysql-community-client', 'mysql-community-server' ]
        }
        default: { fail("Unsupported RHEL/CentOS version! - ${::operatingsystemrelease}")  }
      }
    }
    'Debian':
    {
      $perconatoolkit_wgetcmd='bash -c \'echo https://www.percona.com$(curl https://www.percona.com/downloads/percona-toolkit/ 2>&1 | grep -Eo \'href="[^"]*deb"\' | cut -f 2 -d\")\''

      case $::operatingsystem
      {
        'Ubuntu':
        {
          case $::operatingsystemrelease
          {
            /^14.*$/:
            {
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
