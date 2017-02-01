# == Class: mysql
#
# === mysql documentation
#
class mysql(
                            $password              = 'password',
                            $remove_data_dir       = false,
                            $manage_package        = true,
                            $package_ensure        = 'installed',
                            $manage_service        = true,
                            $manage_docker_service = true,
                            $service_ensure        = 'running',
                            $service_enable        = true,
                            $version               = '5.7',
                            $flavor                = 'community',
                            $srcdir                = '/usr/local/src',
                            $binlog_format         = $mysql::params::binlog_format_default,
                            $charset               = $mysql::params::charset_default,
                            $datadir               = $mysql::params::datadir_default,
                            $expirelogsdays        = $mysql::params::expirelogsdays_default,
                            $ignoreclientcharset   = $mysql::params::ignoreclientcharset_default,
                            $readonly              = $mysql::params::readonly_default,
                            $serverid              = $mysql::params::serverid_default,
                            $skip_external_locking = $mysql::params::skip_external_locking_default,
                            $tmpdir                = $mysql::params::tmpdir_default,
                            $key_buffer_size       = $mysql::params::key_buffer_size_default,
                          ) inherits mysql::params{

  class { '::mysql::install': } ->
  class { '::mysql::config': } ~>
  class { '::mysql::service': } ->
  Class['::mysql']

}
