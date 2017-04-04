define mysql::mycnf::galera (
                              $wsrep_node_address              = $::ipaddress,
                              $wsrep_cluster_address           = [],
                              $instance_name                   = $name,
                              $wsrep_provider                  = '/usr/lib/libgalera_smm.so',
                              $wsrep_sst_method                = 'xtrabackup-v2',
                              $wsrep_cluster_name              = 'my_wsrep_cluster',
                              $wsrep_sst_auth_username         = 'dmlzY2EK',
                              $wsrep_sst_auth_password         = 'Y2F0YWx1bnlhCg',
                              $wsrep_dirty_reads               = false,
                              $wsrep_desync                    = false,
                              $wsrep_reject_queries            = 'NONE',
                              $wsrep_sst_donor                 = undef,
                              $wsrep_sst_donor_rejects_queries = false,
                              $gmcast_listen_addr              = 'tcp://0.0.0.0:4567',
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
