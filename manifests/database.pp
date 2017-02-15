define mysql::database(
                        $dbname        = $name,
                        $instance_name = undef,
                        $charset       = 'utf8',
                        $collate       = 'utf8_general_ci',
                      ) {
  Mysql_sql {
    instance_name => $instance_name,
  }

  mysql_sql { 'db ${dbname}':
    command => "CREATE DATABASE ${dbname} CHARACTER SET ${charset} COLLATE ${collate}",
    unless => "SHOW DATABASES like '${dbname}'",
  }
}
