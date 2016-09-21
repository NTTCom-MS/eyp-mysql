# == Class: mysql
#
# === mysql documentation
#
class mysql(
                            $password              = 'password',
                            $manage_package        = true,
                            $package_ensure        = 'installed',
                            $manage_service        = true,
                            $manage_docker_service = true,
                            $service_ensure        = 'running',
                            $service_enable        = true,
                            $version               = '5.7',
                            $flavor                = 'community',
                            $srcdir                = '/usr/local/src',
                          ) inherits mysql::params{

  class { '::mysql::install': } ->
  class { '::mysql::config': } ~>
  class { '::mysql::service': } ->
  Class['::mysql']

}
