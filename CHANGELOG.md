# CHANGELOG

## 0.4

* **INCOMPATIBLE CHANGE**: major rewrite, not intended to be compatible with eyp-mysql 0.3 or lower in any way

### 0.4.1

## 0.3

* **INCOMPATIBLE CHANGE**: backup scripts moved to namespace **mysql::backup**:
  * **mysql::backupmysqldump** moved to **mysql::backup::mysqldump**
* added backup wrapper for xtrabackup (versions 2.0.8 and 2.4.4)
