# CHANGELOG

Major changes:

## 0.3

* **INCOMPATIBLE CHANGE**: backup scripts moved to namespace **mysql::backup**:
  * **mysql::backupmysqldump** moved to **mysql::backup::mysqldump**
* added backup wrapper for xtrabackup (versions 2.0.8 and 2.4.4)
