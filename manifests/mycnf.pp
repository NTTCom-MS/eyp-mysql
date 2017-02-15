#
# Nota:
# Beginning with MySQL 5.0.4, it is possible to use !include directives in option files to include other
# option files and !includedir to search specific directories for option
#
# concat my.cnf
# 000 puppet managed file banner
#
# 100 mysqld
# 101 general
# 102 charset
#
define mysql::mycnf (
                      $instance_name = $name,
                      $ensure        = 'present',
                      $owner         = 'root',
                      $group         = 'root',
                      $mode          = '0644',
                    ) {

  if($instance_name=='global')
  {
    concat { '/etc/mysql/my.cnf':
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
    }

    concat::fragment{ '/etc/mysql/my.cnf header':
      target  => '/etc/mysql/my.cnf',
      order   => '000',
      content => "#\n# puppet managed file\n#\n\n",
    }
  }
  else
  {
    file { "/etc/mysql/${instance_name}":
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      purge   => true,
    }

    concat { "/etc/mysql/${instance_name}/my.cnf":
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      require => File["/etc/mysql/${instance_name}"],
      tag     => "eypmysql_${instance_name}",
    }

    concat::fragment{ "/etc/mysql/${instance_name}/my.cnf header":
      target  => "/etc/mysql/${instance_name}/my.cnf",
      order   => '000',
      content => "#\n# puppet managed file\n#\n\n",
    }
  }
}
