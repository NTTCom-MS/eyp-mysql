class mysql::params {

	$mariadb_packages= [ 'mariadb-server-5.5', 'mariadb-client-5.5' ]
	case $::osfamily
	{
		'redhat':
    {
      case $::operatingsystemrelease
      {
        /^5.*$/:
        {
					$mysql_repo_pkg_url={ '5.7' => 'http://dev.mysql.com/get/mysql57-community-release-el5-7.noarch.rpm' }
					$package_provider="rpm"
					$mysql_comunity_repo_package={ '5.7' => 'mysql57-community-release'}

					$mysql_community_packages= [ 'mysql-community-client', 'mysql-community-server' ]
        }
				/^6.*$/:
				{
					$mysql_repo_pkg_url={ '5.7' => 'http://dev.mysql.com/get/mysql57-community-release-el6-7.noarch.rpm' }
					$package_provider="rpm"
					$mysql_comunity_repo_package={ '5.7' => 'mysql57-community-release'}

					$mysql_community_packages= [ 'mysql-community-client', 'mysql-community-server' ]
				}
        default: { fail("Unsupported RHEL/CentOS version! - $::operatingsystemrelease")  }
      }
    }
		'Debian':
		{
			case $::operatingsystem
			{
				'Ubuntu':
				{
					case $::operatingsystemrelease
					{
						/^14.*$/:
						{
						}
						default: { fail("Unsupported Ubuntu version! - $::operatingsystemrelease")  }
					}
				}
				'Debian': { fail("Unsupported")  }
				default: { fail("Unsupported Debian flavour!")  }
			}
		}
		default: { fail("Unsupported OS!")  }
	}

}
