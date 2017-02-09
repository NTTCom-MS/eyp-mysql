# notes:
# tmp_table_size=max_heap_table_size
define mysql::mycnf::mysqld (
                              $instance_name          = $name,
                              $skip_external_locking  = $mysql::params::skip_external_locking_default,
                              $tmpdir                 = $mysql::params::tmpdir_default,
                              $datadir                = "/var/mysql/${name}",
                              $default_storage_engine = 'InnoDB',
                              $ignoreclientcharset    = true,
                              $charset                = 'utf8',
                              $readonly               = false,
                            ) {
  if($instance_name=='global')
  {
    $mycnf_path='/etc/mysql/my.cnf'
  }
  else
  {
    $mycnf_path="/etc/mysql/${instance_name}/my.cnf"
  }

  concat::fragment{ "/etc/mysql/${instance_name}/my.cnf header mysqld":
    target  => "/etc/mysql/${instance_name}/my.cnf",
    order   => '100',
    content => "[mysqld]\n\n",
  }

  concat::fragment{ "/etc/mysql/${instance_name}/my.cnf mysqld general":
    target  => "/etc/mysql/${instance_name}/my.cnf",
    order   => '101',
    content => template("${module_name}/mycnf/mysqld/01_general.erb"),
  }

  concat::fragment{ "/etc/mysql/${instance_name}/my.cnf mysqld charset":
    target  => "/etc/mysql/${instance_name}/my.cnf",
    order   => '102',
    content => template("${module_name}/mycnf/mysqld/02_charset.erb"),
  }

  concat::fragment{ "/etc/mysql/${instance_name}/my.cnf mysqld RW status":
    target  => "/etc/mysql/${instance_name}/my.cnf",
    order   => '103',
    content => template("${module_name}/mycnf/mysqld/03_rw.erb"),
  }
}
