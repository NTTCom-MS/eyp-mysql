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

A one-maybe-two sentence summary of what the module does/what problem it solves.
This is your 30 second elevator pitch for your module. Consider including
OS/Puppet version it works with.

## Module Description

If applicable, this section should have a brief description of the technology
the module integrates with and what that integration enables. This section
should answer the questions: "What does this module *do*?" and "Why would I use
it?"

If your module has a range of functionality (installation, configuration,
management, etc.) this is the time to mention it.

## Setup

### What mysql affects

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

### Setup Requirements

This module requires pluginsync enabled

### Beginning with mysql

The very basic steps needed for a user to get the module up and running.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you may wish to include an additional section here: Upgrading
(For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

## Usage

### xtrabackup

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

## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

This is where you list OS compatibility, version compatibility, etc.

## Development

We are pushing to have acceptance testing in place, so any new feature should
have some test to check both presence and absence of any feature

### TODO

TODO list

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
