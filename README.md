# mysql

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with mysql](#setup)
    * [What mysql affects](#what-mysql-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with mysql](#beginning-with-mysql)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

MySQL setup

## Module Description

TODO

## Setup

### What mysql affects

TODO

### Setup Requirements

TODO

### Beginning with mysql

To setup MySQL with a single DB and a backup script (mysqldump):

```puppet
class { 'mysql::mariadb':
  rootpw   => 'a',
  debianpw => 'b',
}

mysql_database { 'et2blog':
  ensure => 'present',
}

mysql::backupmysqldump { 'backupmysql':
  destination => '/mybackups',
  logdir      => '/mybackups',
  retention => 15,
  compress => true,
}

```

## Usage

```puppet
class { 'mysql::mariadb':
  rootpw   => 'a',
  debianpw => 'b',
}

 mysql_database { 'lol':
 	ensure => 'present',
 }

mysql::backupmysqldump { 'backupmysql':
  destination => '/mybackups',
  logdir      => '/mybackups',
  retention => 15,
  compress => true,
}
```

## Reference

TODO

## Limitations

Tested on Ubuntu 14.04

## Development

We are pushing to have acceptance testing in place, so any new feature should
have some test to check both presence and absence of any feature
