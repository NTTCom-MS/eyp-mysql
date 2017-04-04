# mysql

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What mysql affects](#what-mysql-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with mysql](#beginning-with-mysql)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)
    * [TODO](#todo)
    * [Contributing](#contributing)

## Overview

multi instance / multi flavor MySQL management

## Module Description

multi instance / multi flavor MySQL management:
* MySQL Community
* XtraDB Cluster (percona's Galera)

## Setup

### What mysql affects

* installs percona repo (if needed)
* installs MySQL packages
* manages configuration files (**/etc/mysql**) - it's not possible to have a unmanaged MySQL instance

### Setup Requirements

This module requires pluginsync enabled

### Beginning with mysql

```puppet
mysql::community::instance { 'test':
  port              => '3306',
  password          => 'password',
  add_default_mycnf => true,
}

mysql::community::instance { 'test2':
  port              => '3307',
  password          => 'password',
  add_default_mycnf => true,
}
```

## Usage

### single node demo XtraDB cluster

```puppet
mysql::xtradbcluster::instance { 'cluster1':
  cluster_name       => 'galera',
  port						   => '3306',
  bootstrap          => true,
  password           => 'password',
  serverid           => '1',
  default_instance   => true,
  cluster_list       => [ '192.168.56.103:4568' ],
  sst_username       => 'sstuser',
  sst_password       => 'sstpassw0rd',
  node_address       => '192.168.56.103',
  gmcast_listen_addr => 'tcp://0.0.0.0:4567'
}

->

mysql::xtradbcluster::instance { 'cluster2':
  cluster_name       => 'galera',
  port						   => '3307',
  bootstrap          => false,
  password           => 'password',
  serverid           => '2',
  default_instance   => false,
  cluster_list       => [ '192.168.56.103:4567' ],
  sst_username       => 'sstuser',
  sst_password       => 'sstpassw0rd',
  node_address       => '192.168.56.103',
  gmcast_listen_addr => 'tcp://0.0.0.0:4568'
}
```

*Note: Once cluster is bootstraped we need to change bootstrap to false in the primary node*

### backup scripts

install backup script using xtrabackup tool for **cluster1** instance:

```puppet
mysql::backup::xtrabackup { 'cluster1':
  destination => '/backup',
}
```

install backup script for **galera** instance using hiera:

```yaml
xtrabackup:
  'galera':
    hour: '3'
    minute: '0'
    destination: '/var/mysql/backup'
    idhost: 'EXAMPLE001'
    mailto: 'backups@backups.systemadmin.es'
    retention: '5'
```

### misc

run SQL query

```puppet
mysql_sql { 'caca':
  command => 'select version()',
  instance_name => 'test',
}
```

create database

```puppet
mysql::database { 'provaprova': }
```

## Reference

### classes

#### mysql::tools::innochecksum

* **binpath**: place to install innochecksum tool (default: /usr/local/bin/innochecksum)

### defines

#### mysql::backup::xtrabackup

* general options:
  * **destination**:
  * **retention**:           = undef,
  * **logdir**:              = undef,
  * **mailto**:              = undef,
  * **idhost**:              = undef,
  * **backupscript**: backup script path (default: /usr/local/bin/backup_xtrabackup)
  * **backupid**:            = 'MySQL',
  * **xtrabackup_version**: xtrabackup version to install (default: 2.4.4)
* full backup related variables:
  * **fullbackup_monthday**: day of month to perform full backups, space padded (default: undef) - **INCOMPATIBLE** with **fullbackup_weekday**
  * **fullbackup_weekday**: day of week (1..7) to perform full backups; 1 is Monday (default: undef) - **INCOMPATIBLE** with **fullbackup_monthday**
* cronjob related variables:
  * **hour**:                = '2',
  * **minute**:              = '0',
  * **month**:               = undef,
  * **monthday**:            = undef,
  * **weekday**:             = undef,
  * **setcron**:             = true,

#### mysql::backup::mysqldump

* **destination**: ,
* **instance**:      = $name,
* **retention**:     = undef,
* **logdir**:        = undef,
* **compress**:      = true,
* **mailto**:        = undef,
* **idhost**:        = undef,
* **backupscript**:  = '/usr/local/bin/backupmysqldump',
* **hour**:          = '2',
* **minute**:        = '0',
* **month**:         = undef,
* **monthday**:      = undef,
* **weekday**:       = undef,
* **setcron**:       = true,

## Limitations

This is where you list OS compatibility, version compatibility, etc.

## Development

We are pushing to have acceptance testing in place, so any new feature should
have some test to check both presence and absence of any feature

### TODO

* On Ubuntu fails to install because packages are starting the service before being configured. Should be installed using RUNLEVEL=1 (puppet package provider does not support environment variables) or to use a similar approach

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
