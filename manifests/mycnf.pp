#
# Nota:
# Beginning with MySQL 5.0.4, it is possible to use !include directives in option files to include other
# option files and !includedir to search specific directories for option
#
# concat my.cnf
# 00 puppet managed file banner
#
define mysql::mycnf (
                      $mycnf  = $name,
                      $ensure = 'present',
                      $owner  = 'root',
                      $group  = 'root',
                      $mode   = '0644',
                    ) {

  concat { $mycnf:
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
  }

  concat::fragment{ "${mycnf} header":
    target  => $mycnf,
    order   => '00',
    content => "#\n# puppet managed file\n#\n\n",
  }
}
