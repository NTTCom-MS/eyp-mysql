class mysql (
              $password                 = 'password',
              $remove_data_dir          = false,
              $manage_package           = true,
              $package_ensure           = 'installed',
              $manage_service           = $mysql::params::manage_default_service,
              $manage_docker_service    = true,
              $service_ensure           = 'stopped',
              $service_enable           = false,
              $version                  = undef,
              $flavor                   = undef,
              $srcdir                   = '/usr/local/src',
              $binlog_format            = $mysql::params::binlog_format_default,
              $charset                  = $mysql::params::charset_default,
              $datadir                  = $mysql::params::datadir_default,
              $expirelogsdays           = $mysql::params::expirelogsdays_default,
              $ignoreclientcharset      = $mysql::params::ignoreclientcharset_default,
              $readonly                 = $mysql::params::readonly_default,
              $serverid                 = $mysql::params::serverid_default,
              $skip_external_locking    = $mysql::params::skip_external_locking_default,
              $tmpdir                   = $mysql::params::tmpdir_default,
              $key_buffer_size          = $mysql::params::key_buffer_size_default,
              # v4
              $add_default_global_mycnf = true,
              $pid_location             = $mysql::params::pid_location_default,
              $mysql_username           = 'mysql',
              $mysql_username_uid       = $mysql::params::mysql_username_uid_default,
              $mysql_username_gid       = $mysql::params::mysql_username_gid_default,
            ) inherits mysql::params{

  class { '::mysql::service': } ->
  class { '::mysql::install': } ->
  class { '::mysql::config': } ->
  Class['::mysql']

}
