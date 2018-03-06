define mysql::backup::xtrabackup (
                                    $destination,
                                    $instance            = $name,
                                    $retention           = undef,
                                    $logdir              = undef,
                                    $mailto              = undef,
                                    $idhost              = undef,
                                    $backupscript        = '/usr/local/bin/backup_xtrabackup',
                                    $hour                = '2',
                                    $minute              = '0',
                                    $month               = undef,
                                    $monthday            = undef,
                                    $weekday             = undef,
                                    $setcron             = true,
                                    $backupid            = 'MySQL',
                                    $xtrabackup_version  = '2.4.4',
                                    $fullbackup_monthday = undef,
                                    $fullbackup_weekday  = undef,
                                  ) {

  if ($fullbackup_monthday!=undef and $fullbackup_weekday!=undef)
  {
    fail('fullbackup_monthday and fullbackup_weekday cannot be defined at the same time')
  }

  if defined(Class['netbackupclient'])
  {
    netbackupclient::includedir { $destination: }
  }

  exec { "xtrabackup mkdir_p_${destination}":
    command => "/bin/mkdir -p ${destination}",
    creates => $destination,
  }

  file { $destination:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => Exec["xtrabackup mkdir_p_${destination}"]
  }

  # backup script

  file { $backupscript:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => file("${module_name}/backup/xtrabackup/backupxtrabackup")
  }

  file { "${backupscript}.config":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template("${module_name}/backup/xtrabackup/backupxtrabackupconfig.erb")
  }


  if($setcron)
  {
    cron { "cronjob mysqldump ${name}":
      command  => $backupscript,
      user     => 'root',
      hour     => $hour,
      minute   => $minute,
      month    => $month,
      monthday => $monthday,
      weekday  => $weekday,
      require  => File[ [ $backupscript, $destination, "${backupscript}.config" ] ],
    }
  }

  #
  # https://www.percona.com/doc/percona-xtrabackup/2.3/installation.html#installing-percona-xtrabackup-from-repositories
  #
  if(!defined(Class['mysql::backup::xtrabackup::install']))
  {
    class { 'mysql::backup::xtrabackup::install':
      version => $xtrabackup_version,
    }
  }

}
