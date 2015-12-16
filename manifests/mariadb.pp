#
class mysql::mariadb	(
				$version='5.5',
				$datadir='/var/mysql/datadir/',
				$binlogdir='/var/mysql/binlogs',
				$relaylogdir='/var/mysql/binlogs',
				$logdir='/var/log/mysql/',
				$srcdir='/usr/local/src',
				$rootpw,
				$debianpw,
				$ensure='installed',
				$slave=false,
				$readonly=false,
				$charset='utf8',
				$ignoreclientcharset=false,
				$expirelogsdays='5',
				$serverid='1'
			) inherits params {

	validate_re($version, [ '^5.5$' ], "Not a supported version: ${version}")
	validate_re($ensure, [ '^installed$', '^latest$' ], "ensure: installed/latest (${ensure} is not supported)")

	validate_absolute_path($datadir)
	validate_absolute_path($binlogdir)
	validate_absolute_path($logdir)
	validate_absolute_path($relaylogdir)

	validate_bool($readonly)


	Exec {
		path => '/usr/sbin:/usr/bin:/sbin:/bin',
	}

	if defined(Class['ntteam'])
	{
		ntteam::tag{ 'mariadb': }
	}


	$mysqldirs = [ $datadir, $binlogdir ]
	file { $mysqldirs:
		ensure  => 'directory',
		owner   => 'mysql',
		group   => 'root',
		mode    => '775',
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
		creates => "${datadir}",
		require => Package[$mariadb_packages],
	}

	exec { "mkdir p binlogdir ${binlogdir}":
		command => "mkdir -p ${binlogdir} ",
		creates => "${binlogdir}",
		require => Package[$mariadb_packages],
	}

	exec { "mkdir p logdir ${logdir}":
		command => "mkdir -p ${logdir} ",
		creates => "${logdir}",
		require => Package[$mariadb_packages],
	}

	exec { 'stop mysqld':
		command     => 'bash -c \'pkill mysqld; mv /var/lib/mysql /var/lib/old.mysql;\'',
		refreshonly => true,
		require     => File[ [$datadir, $binlogdir, $logdir] ],
	}

	package { $mariadb_packages:
		ensure => $ensure,
		notify => Exec['stop mysqld'],
	}

	file { '/etc/mysql/my.cnf':
		ensure  => present,
		owner   => "root",
		group   => "root",
		mode    => 0644,
		require => Exec['stop mysqld'],
		notify  => Service['mysql'],
		content => template("mysql/mycnf.erb"),
		backup  => '.puppet-mycnf-back',
	}

	file { '/etc/mysql/debian.cnf':
		ensure    => present,
		owner     => "root",
		group     => "root",
		mode      => 0640,
		require   => Package[$mariadb_packages],
		content   => template("mysql/debiancnf.erb"),
		backup    => '.puppet-debiancnf-back',
		show_diff => false,
	}

	exec {'install db mariadb':
		command => "/usr/bin/mysql_install_db --user=mysql --datadir=${datadir}",
		require => File[ [ '/etc/mysql/my.cnf','/etc/mysql/debian.cnf' ] ],
		creates => "${datadir}/mysql/user.frm",
	}

	file { "${datadir}/.mysql.root.pass":
		ensure    => 'present',
		owner     => 'root',
		group     => 'root',
		mode      => '0400',
		content   => "${rootpw}\n",
		require   => Exec['install db mariadb'],
		notify    => Exec['set root pw'],
		show_diff => false,
	}


	file { "${datadir}/.mysql.debian.pass":
		ensure    => 'present',
		owner     => 'root',
		group     => 'root',
		mode      => '0400',
		content   => "${debianpw}\n",
		require   => Exec['install db mariadb'],
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
