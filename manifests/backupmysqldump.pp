define mysql::backupmysqldump (
        $destination,
        $retention=undef,
        $logdir=undef,
        $compress=true,
        $mailto=undef,
        $idhost=undef,
        $backupscript='/usr/local/bin/backupmysqldump',
        $hour='2',
        $minute='0',
        $month=undef,
        $monthday=undef,
        $weekday=undef,
        $setcron=true,
      ) {
  #
  validate_absolute_path($destination)

  if defined(Class['netbackupclient'])
  {
    netbackupclient::includedir{ $destination: }
  }

  exec { "backupmysqldump mkdir_p_$destination":
    command => "/bin/mkdir -p $destination",
    creates => $destination,
  }

  file { $destination:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => Exec["backupmysqldump mkdir_p_$destination"]
  }

  file { $backupscript:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template("${module_name}/backupmysqldump.erb")
  }

  file { "${backupscript}.config":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template("${module_name}/backupmysqldumpconfig.erb")
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
