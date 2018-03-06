#http://bugs.mysql.com/bug.php?id=57611&files=1

#  Copyright (C) 2000-2005 MySQL AB & Innobase Oy
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; version 2 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA */
#
#
# InnoDB offline file checksum utility.  85% of the code in this file
# was taken wholesale fron the InnoDB codebase.
#
# The final 15% was originally written by Mark Smith of Danga
# Interactive, Inc. <junior@danga.com>
#
# Published with a permission.
#
class mysql::tools::innochecksum  (
                                    $binpath = '/usr/local/bin/innochecksum'
                                  ) inherits mysql::params {

  file { $binpath:
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/innochecksum",
  }

}
