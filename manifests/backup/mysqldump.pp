define mysql::backup::mysqldump (
                                  $destination,
                                  $instance	      = $name,
                                  $retention	    = undef,
                                  $logdir         = undef,
                                  $compress	      = true,
                                  $inlinecompress = false,
                                  $mailto         = undef,
                                  $idhost         = undef,
                                  $backupscript   = '/usr/local/bin/backupmysqldump',
                                  $hour           = '2',
                                  $minute         = '0',
                                  $month          = undef,
                                  $monthday       = undef,
                                  $weekday        = undef,
                                  $backupid       = 'MySQL',
                                  $setcron        = true,
                                  $masterdata     = '1',
                                  $file_per_db    = true,
                                  $extraopts      = undef,
                                ) {

  if defined(Class['netbackupclient'])
  {
    netbackupclient::includedir { $destination: }
  }

  exec { "backupmysqldump mkdir_p_${destination}":
    command => "/bin/mkdir -p ${destination}",
    creates => $destination,
  }

  file { $destination:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => Exec["backupmysqldump mkdir_p_${destination}"]
  }

  file { $backupscript:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => file("${module_name}/backup/mysqldump/backupmysqldump")
  }

  file { "${backupscript}.config":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template("${module_name}/backup/mysqldump/backupmysqldumpconfig.erb")
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

}
