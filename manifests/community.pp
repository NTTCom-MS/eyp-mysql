#
class mysql::community  (
        #MySQL
        $binlogdir=$mysql::params::binlogdir_default,
        $binlog_format=$mysql::params::binlog_format_default,
        $charset=$mysql::params::charset_default,
        $datadir=$mysql::params::datadir_default,
        $debianpw,
        $ensure=$mysql::params::ensure_default,
        $expirelogsdays=$mysql::params::expirelogsdays_default,
        $ignoreclientcharset=$mysql::params::ignoreclientcharset_default,
        $innodb_buffer_pool_size=$mysql::params::innodb_buffer_pool_size_default,
        $innodb_log_file_size=$mysql::params::innodb_log_file_size_default,
        $join_buffer_size=$mysql::params::join_buffer_size_default,
        $key_buffer_size=$mysql::params::key_buffer_size_default,
        $logdir=$mysql::params::logdir_default,
        $max_binlog_size=$mysql::params::max_binlog_size_default,
        $max_connections=$mysql::params::max_connections_default,
        $max_heap_table_size=$mysql::params::max_heap_table_size_default,
        $max_relay_log_size=$mysql::params::max_relay_log_size_default,
        $max_user_connections=$mysql::params::max_user_connections_default,
        $open_files_limit=$mysql::params::open_files_limit_default,
        $query_cache_limit=$mysql::params::query_cache_limit_default,
        $query_cache_size=$mysql::params::query_cache_size_default,
        $readonly=$mysql::params::readonly_default,
        $relaylogdir=$mysql::params::relaylogdir_default,
        $replicate_ignore_db=$mysql::params::replicate_ignore_db_default,
        $rootpw,
        $serverid=$mysql::params::serverid_default,
        $skip_external_locking=$mysql::params::skip_external_locking_default,
        $slave=$mysql::params::slave_default,
        $sort_buffer_size=$mysql::params::sort_buffer_size_default,
        $srcdir=$mysql::params::srcdir_default,
        $table_open_cache=$mysql::params::table_open_cache_default,
        $thread_cache_size=$mysql::params::thread_cache_size_default,
        $thread_stack=$mysql::params::thread_stack_default,
        $tmpdir=$mysql::params::tmpdir_default,

        #community specific
        $version=$mysql::params::community_version_default,

        #mysqldump config
        $mysqldump_quick=$mysql::params::mysqldump_quick_default,
        $mysqldump_quote_names=$mysql::params::mysqldump_quote_names_default,

        #isamchk config
        $isamchk_key_buffer=$mysql::params::isamchk_key_buffer_default,
      ) inherits mysql::params {

  validate_re($version, [ '^5.6$' ], "Not a supported version: ${version}")
  validate_re($ensure, [ '^installed$', '^latest$' ], "ensure: installed/latest (${ensure} is not supported)")

  validate_absolute_path($datadir)
  validate_absolute_path($binlogdir)
  validate_absolute_path($logdir)
  validate_absolute_path($relaylogdir)

  validate_bool($readonly)

  validate_string($binlog_format)
  validate_string($charset)
  validate_string($debianpw)
  validate_string($expirelogsdays)
  validate_bool($ignoreclientcharset)
  validate_string($innodb_buffer_pool_size)
  validate_string($innodb_log_file_size)
  validate_string($join_buffer_size)
  validate_string($key_buffer_size)
  validate_string($max_binlog_size)
  validate_string($max_connections)
  validate_string($max_heap_table_size)
  validate_string($max_relay_log_size)
  validate_string($max_user_connections)
  validate_string($open_files_limit)
  validate_string($query_cache_limit)
  validate_string($query_cache_size)
  if($replicate_ignore_db)
  {
    validate_array($replicate_ignore_db)
  }
  validate_string($rootpw)
  validate_string($serverid)
  validate_bool($skip_external_locking)
  validate_bool($slave)
  validate_string($sort_buffer_size)
  validate_absolute_path($srcdir)
  validate_string($table_open_cache)
  validate_string($thread_cache_size)
  validate_string($thread_stack)
  if($tmpdir)
  {
    validate_absolute_path($tmpdir)
  }
  validate_string($version)

  validate_bool($mysqldump_quick)
  validate_bool($mysqldump_quote_names)

  if($isamchk_key_buffer)
  {
    validate_string($isamchk_key_buffer)
  }



  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  if defined(Class['ntteam'])
  {
    ntteam::tag{ 'community': }
  }


  $mysqldirs = [ $datadir, $binlogdir ]
  file { $mysqldirs:
    ensure  => 'directory',
    owner   => 'mysql',
    group   => 'root',
    mode    => '0775',
    require => Exec[ [ "mkdir p datadir ${datadir}", "mkdir p binlogdir ${binlogdir}", "mkdir p logdir ${logdir}" ] ],
  }

  file { $logdir:
    ensure  => 'directory',
    owner   => 'mysql',
    group   => 'adm',
    mode    => '2750',
    require => Exec[ [ "mkdir p datadir ${datadir}", "mkdir p binlogdir ${binlogdir}", "mkdir p logdir ${logdir}" ] ],
  }

  exec { "mkdir p datadir ${datadir}":
    command => "mkdir -p ${datadir} ",
    creates => $datadir,
    require => Package[$mysql::params::community_packages],
  }

  exec { "mkdir p binlogdir ${binlogdir}":
    command => "mkdir -p ${binlogdir} ",
    creates => $binlogdir,
    require => Package[$mysql::params::community_packages],
  }

  exec { "mkdir p logdir ${logdir}":
    command => "mkdir -p ${logdir} ",
    creates => $logdir,
    require => Package[$mysql::params::community_packages],
  }

  exec { 'stop mysqld':
    command     => 'bash -c \'pkill mysqld; mv /var/lib/mysql /var/lib/old.mysql;\'',
    refreshonly => true,
    require     => File[ [$datadir, $binlogdir, $logdir] ],
  }

  package { $mysql::params::community_packages:
    ensure => $ensure,
    notify => Exec['stop mysqld'],
  }

  file { '/etc/mysql/my.cnf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Exec['stop mysqld'],
    notify  => Service['mysql'],
    content => template("${module_name}/mycnf.erb"),
    backup  => '.puppet-mycnf-back',
  }

  file { '/etc/mysql/debian.cnf':
    ensure    => present,
    owner     => 'root',
    group     => 'root',
    mode      => '0640',
    require   => Package[$mysql::params::community_packages],
    content   => template("${module_name}/debiancnf.erb"),
    backup    => '.puppet-debiancnf-back',
    show_diff => false,
  }

  file { '/usr/share/mysql/my-default.cnf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/mysql/my.cnf'],
    content => Exec['cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf'],
  }

  exec {'install db community':
    command => "/usr/bin/mysql_install_db --user=mysql --datadir=${datadir}",
    require => File[ [ '/etc/mysql/my.cnf','/etc/mysql/debian.cnf', '/usr/share/mysql/my-default.cnf' ] ],
    creates => "${datadir}/mysql/user.frm",
  }

  file { "${datadir}/.mysql.root.pass":
    ensure    => 'present',
    owner     => 'root',
    group     => 'root',
    mode      => '0400',
    content   => "${rootpw}\n",
    require   => Exec['install db community'],
    notify    => Exec['set root pw'],
    show_diff => false,
  }


  file { "${datadir}/.mysql.debian.pass":
    ensure    => 'present',
    owner     => 'root',
    group     => 'root',
    mode      => '0400',
    content   => "${debianpw}\n",
    require   => Exec['install db community'],
    show_diff => false,
    notify    => Exec['set debian pw'],
  }

  service { 'mysql':
    ensure  => 'running',
    enable  => true,
    require => File["${datadir}/.mysql.debian.pass"],
  }


  # debian-sys-maint
  # GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY PASSWORD '*5381B5633F4310DFEB73268D6C7A424E6CCED9A5' WITH GRANT OPTION

  exec { 'set debian pw':
    command     => "bash -c 'echo \"GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER ON *.* TO '\"'\"'debian-sys-maint'\"'\"'@'\"'\"'localhost'\"'\"' IDENTIFIED BY '\"'\"'\$(cat ${datadir}/.mysql.debian.pass)'\"'\"' WITH GRANT OPTION\" | mysql'",
    refreshonly => true,
    require     => Service['mysql'],
  }

  exec { 'set root pw':
    command     => "bash -c 'mysqladmin -u root password \$(cat ${datadir}/.mysql.root.pass)'",
    refreshonly => true,
    require     => Service['mysql'],
    notify      => Exec['postinstall mysql'],
  }

  file { '/root/.my.cnf':
    ensure    => 'present',
    owner     => 'root',
    group     => 'root',
    mode      => '0400',
    content   => "[client]\n\nuser=root\npassword=${rootpw}\n",
    show_diff => false,
    require   => Exec['set root pw'],
  }

  exec { 'postinstall mysql':
    command     => "bash -c 'echo \"drop database test; delete from mysql.user where password =''; flush privileges;\" | mysql -f -p\$(cat ${datadir}/.mysql.root.pass)'",
    refreshonly => true,
    require     => Service['mysql'],
  }


}
