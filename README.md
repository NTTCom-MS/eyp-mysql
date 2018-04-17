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

backup strategies:
* **mysqldump**: grants + 1 file per DB
* **xtrabackup**: full mode only

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

### single node XtraDB demo cluster

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

#### mysql::perconarepo

percona repo installation

* **srcdir**:         = '/usr/local/src',
* **package_ensure**: = 'installed',

#### mysql::tools::perconatoolkit

percona toolkit installation

* **package_ensure**: = 'installed',

#### mysql::tools::innochecksum

ibdata inspector

* **binpath**: place to install innochecksum tool (default: /usr/local/bin/innochecksum)

### defines

#### mysql::xtradbcluster::instance

#### mysql::community::instance

#### mysql::backup::xtrabackup

* general options:
  - **destination**: Where to store backups - required
  - **retention**: Instance to backup (default: undef)
  - **logdir**: Where to store logs, if not specified any log message is shown via stdout (default: undef)
  - **mailto**: If defined, sends backups notifications via email (default: undef)
  - **idhost**: Optional host identification, if not defined uses hostname (default: undef)
  - **backupscript**: backup script path (default: /usr/local/bin/backup_xtrabackup)
  - **backupid**: How to identify the kind of backup (default: MySQL)
  - **xtrabackup_version**: xtrabackup version to install (default: 2.4.4)
* full backup related variables:
  - **fullbackup_monthday**: day of month to perform full backups, space padded (default: undef) - **INCOMPATIBLE** with **fullbackup_weekday**
  - **fullbackup_weekday**: day of week (1..7) to perform full backups; 1 is Monday (default: undef) - **INCOMPATIBLE** with **fullbackup_monthday**
* cronjob related variables:
  - **setcron**:   - **setcron**: If setcron is true, at which hour to run backup job (default: 2)
  - **hour**: If setcron is true, at which hour to run backup job (default: 2)
  - **minute**: If setcron is true, at which minute to run backup job (default: 0)
  - **month**: If setcron is true, at which month to run backup job (default: undef)
  - **monthday**: If setcron is true, at which monthday to run backup job (default: undef)
  - **weekday**: If setcron is true, at which weekday to run backup job (default: undef)

#### mysql::backup::mysqldump

* general options:
  - **destination**: Where to store backups - required
  - **instance**: Instance to backup (default: undef)
  - **retention**: Backup retention (default: undef)
  - **logdir**: Where to store logs, if not specified any log message is shown via stdout (default: undef)
  - **compress**: Compress backups (default: true)
  - **mailto**: If defined, sends backups notifications via email (default: undef)
  - **idhost**: Optional host identification, if not defined uses hostname (default: undef)
  - **backupscript**: Where to store backup script (default: /usr/local/bin/backupmysqldump)
  - **masterdata**: Use this option to dump a master replication server to produce a dump file that can be used to set up another server as a slave of the master. If the option value is 2, the CHANGE MASTER TO statement is written as an SQL comment, and thus is informative only; it has no effect when the dump file is reloaded. If the option value is 1, the statement is not written as a comment and takes effect when the dump file is reloaded (default: 1)
  - **file_per_db**: Create several dumps, one per DB. It is convenient to perform partial restores but be aware it is not useful for creating slaves (default: true)
* cronjob related variables:
  - **setcron**: If set to true, managed a cronjob to schedule backups (default: true)
  - **hour**: If setcron is true, at which hour to run backup job (default: 2)
  - **minute**: If setcron is true, at which minute to run backup job (default: 0)
  - **month**: If setcron is true, at which month to run backup job (default: undef)
  - **monthday**: If setcron is true, at which monthday to run backup job (default: undef)
  - **weekday**: If setcron is true, at which weekday to run backup job (default: undef)

#### mysql::mycnf::client

* **instance_name**: = $name,
* **client_name**:   = $name,
* **default**:       = false,
* **password**:      = undef,
* **socket**:        = undef,

#### mysql::mycnf::mysqld

* **instance_name**:                   = $name,
* **skip_external_locking**:           = $mysql::params::skip_external_locking_default,
* **tmpdir**:                          = $mysql::params::tmpdir_default,
* **port**:                            = '3306',
* **pidfile**:                         = undef,
* **datadir**:                         = "/var/mysql/${name}",
* **relaylogdir**:                     = "/var/mysql/${name}/relaylogs",
* **binlogdir**:                       = "/var/mysql/${name}/binlogs",
* **default_storage_engine**:          = 'InnoDB',
* **ignoreclientcharset**:             = true,
* **charset**:                         = 'utf8',
* **readonly**:                        = false,
* **key_buffer_size**:                 = $mysql::params::key_buffer_size_default,
* **sysdate_is_now**:                  = true,
* **max_allowed_packet**:              = '16M',
* **max_connect_errors**:              = '1000000',
* **nameresolve**:                     = false,
* **innodb**:                          = 'FORCE',
* **expirelogsdays**:                  = '5',
* **binlog_format**:                   = 'MIXED',
* **sync_binlog**:                     = true,
* **serverid**:                        = '1',
* **max_binlog_size**:                 = '1073741824',
* **log_bin_trust_function_creators**: = false,
* **slave**:                           = false,
* **max_relay_log_size**:              = '0',
* **replicate_ignore_db**:             = [],
* **max_heap_table_size**:             = '32M',
* **tmp_table_size**:                  = '32M',
* **query_cache_type**:                = '0',
* **query_cache_size**:                = '0',
* **query_cache_limit**:               = '1048576',
* **max_connections**:                 = '500',
* **max_user_connections**:            = '0',
* **thread_cache_size**:               = '50',
* **open_files_limit**:                = '65535',
* **table_definition_cache**:          = '4096',
* **table_open_cache**:                = '100',
* **sort_buffer_size**:                = '262144',
* **join_buffer_size**:                = '131072',
* **innodb_flush_method**:             = 'O_DIRECT',
* **innodb_log_files_in_group**:       = '2',
* **innodb_log_file_size**:            = '50331648',
* **innodb_flush_log_at_trx_commit**:  = '2',
* **innodb_file_per_table**:           = true,
* **innodb_buffer_pool_size**:         = ceiling(sprintf('%f', $::memorysize_mb)\*838860),
* **innodb_autoinc_lock_mode**:        = undef,
* **log_queries_not_using_indexes**:   = false,
* **slow_query_log**:                  = true,
* **log_error**:                       = "/var/log/mysql/${name}/mysql-error.log",
* **slow_query_log_file**:             = "/var/log/mysql/${name}/mysql-slow.log",

#### mysql::mycnf::galera

* **wsrep_node_address**:              = $::ipaddress,
* **wsrep_cluster_address**:           = [],
* **instance_name**:                   = $name,
* **wsrep_provider**:                  = '/usr/lib/libgalera_smm.so',
* **wsrep_sst_method**:                = 'xtrabackup-v2',
* **wsrep_cluster_name**:              = 'my_wsrep_cluster',
* **wsrep_sst_auth_username**:         = 'dmlzY2EK',
* **wsrep_sst_auth_password**:         = 'Y2F0YWx1bnlhCg',
* **wsrep_dirty_reads**:               = false,
* **wsrep_desync**:                    = false,
* **wsrep_reject_queries**:            = 'NONE',
* **wsrep_sst_donor**:                 = undef,
* **srep_sst_donor_rejects_queries**: = false,
* **gmcast_listen_addr**:              = 'tcp://0.0.0.0:4567',

## Limitations

Tested on:

* Ubuntu 16.04
* Ubuntu 14.04
* CentOS 6
* CentOS 7

## Development

We are pushing to have acceptance testing in place, so any new feature should
have some test to check both presence and absence of any feature

### TODO

* **xtrabackup**: incremental mode
* On Ubuntu fails to install because packages are starting the service before being configured. Should be installed using RUNLEVEL=1 (puppet package provider does not support environment variables) or to use a similar approach

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
