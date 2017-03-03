define mysql::mycnf::galera (
                              $wsrep_node_address      = $::ipaddress,
                              $wsrep_cluster_address   = [],
                              $instance_name           = $name,
                              $wsrep_provider          = '/usr/lib/libgalera_smm.so',
                              $wsrep_sst_method        = 'xtrabackup',
                              $wsrep_cluster_name      = 'my_wsrep_cluster',
                              $wsrep_sst_auth_username = '',
                              $wsrep_sst_auth_password = '',
                              $wsrep_desync            = false,
                              $wsrep_reject_queries    = 'NONE',
                              $wsrep_sst_donor         = undef,
                              $wsrep_sst_donor_rejects_queries = false,
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
