define mysql::mycnf::galera (
                              $instance_name      = $name,
                              $wsrep_provider     = '/usr/lib/libgalera_smm.so',
                              $wsrep_sst_method   = 'xtrabackup',
                              $wsrep_cluster_name = 'my_wsrep_cluster',
                            ) {
  #
  if($instance_name=='global')
  {
    $mycnf_path='/etc/mysql/my.cnf'
  }
  else
  {
    $mycnf_path="/etc/mysql/${instance_name}/my.cnf"
  }

  concat::fragment{ "${mycnf_path} galera config":
    target  => $mycnf_path,
    order   => '180',
    content => template("${module_name}/mycnf/mysqld/80_galera.erb"),
  }
}
