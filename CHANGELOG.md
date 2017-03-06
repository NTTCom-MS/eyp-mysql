# CHANGELOG

## 0.4.2

* added mysql user and group under puppet management
* added percona repo support
* **INCOMPATIBLE CHANGE**: xtrabackup is now installed using perconarepo
* added support for xtrabackup in Ubuntu 16.04
* added Percona XtraDB cluster support
* **INCOMPATIBLE CHANGE**: added **mysql::pid_location** to define where to store instance's pid file (default: run)

## 0.4.1

**INCOMPATIBLE WITH PREVIOUS VERSIONS**: major rewrite, not intended to be compatible with eyp-mysql 0.3 or lower in any way
* **mysql community**: multi instance
* dropped CentOS 5 support

## 0.3

* **INCOMPATIBLE CHANGE**: backup scripts moved to namespace **mysql::backup**:
  * **mysql::backupmysqldump** moved to **mysql::backup::mysqldump**
* added backup wrapper for xtrabackup (versions 2.0.8 and 2.4.4)
