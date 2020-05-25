# CHANGELOG

## 0.4.21

* Added github actions
* Updated systemd dependency
* mysql backup script:
  - added option to exclude a set of DBs
  - added debug option

## 0.4.20

* modified mysqldump backup script to use inline compression yo save disk space while backing up

## 0.4.19

* Updated metadata for **eyp-systemd 0.2.0**

## 0.4.18

* xtrabackup install needs to happen after mysql deployment
* added GPG for Percona: RPM-GPG-KEY-Percona

## 0.4.17

* Added option to handle extra options for mysqldump

## 0.4.16

* added support for xtrabackup >= 2.4

## 0.4.15

* **backupmysqldump** bugfix: no email being sent when LOGDIR is not set
* added configurable backup id via **backupid** variable to **mysqldump backup script**

## 0.4.14

* bugfix: possible dependency cycle

## 0.4.13

* added **sql_mode** and **lower_case_table_names** to **mysqld section**
* fixed **unless** and **onlyif** for **mysql_sql**
* moved backup scripts to files folder
* minor bugfix mysqldump script
* added **masterdata** and **file_per_db** options to **mysql::backup::mysqldump**

## 0.4.12

* bugfix **backup_xtrabackup** script (no cleanup was performed when MAILTO was undefined)

## 0.4.11

* added **mysql::tools::perconatoolkit**

## 0.4.10

* added Ubuntu14 (sys-v) compatibility for mysqlcommunity and xtradbcluster

## 0.4.9

* bugfix: xtradbcluster binlogdir

## 0.4.8

* changed /var/mysql and instancedir mode from 0750 to 0755
* moved socket from datadir to instancedir
* bugfix: binlog filename

## 0.4.7

* added client connect info using a group in the global my.cnf for **mysqlcommunity**

## 0.4.6

* added client connect info using a group in the global my.cnf for **xtradbcluster**

## 0.4.5

* added options to changed uid and gid for mysql user and group

## 0.4.4

* bugfix: fixed xtrabackup and mysqldump scripts to use the proper my.cnf file

## 0.4.3

* bugfix: Added a dependency for **mysql_install_db** for **mysql::community::instance**
* added **gmcast_listen_addr** variable for *single node* XtraDB clusters (sic)
* added percona repo support for CentOS

## 0.4.2

* added mysql user and group under puppet management
* added percona repo support
* **INCOMPATIBLE CHANGE**: xtrabackup is now installed using perconarepo
* added support for xtrabackup in Ubuntu 16.04
* added Percona XtraDB cluster support
* **INCOMPATIBLE CHANGE**: added **mysql::pid_location** to define where to store instance's pid file
* bugfix: default pid_location for CentOS 7 is datadir (instead of run) due to this bug: [Bug 1428110 - RFE: RuntimeDirectory= should resolve %i and other specifiers](https://bugzilla.redhat.com/show_bug.cgi?id=1428110)

## 0.4.1

**INCOMPATIBLE WITH PREVIOUS VERSIONS**: major rewrite, not intended to be compatible with eyp-mysql 0.3 or lower in any way
* **mysql community**: multi instance
* dropped CentOS 5 support

## 0.3

* **INCOMPATIBLE CHANGE**: backup scripts moved to namespace **mysql::backup**:
  * **mysql::backupmysqldump** moved to **mysql::backup::mysqldump**
* added backup wrapper for xtrabackup (versions 2.0.8 and 2.4.4)
