#!/bin/bash

# TODO: millorar opcions

for i in $(echo "SELECT concat(table_schema,'.',TABLE_NAME) FROM information_schema.TABLES  WHERE TABLE_SCHEMA NOT IN ('information_schema','mysql','performance_schema') AND Data_free is not null and data_free > data_length/10;" | mysql -p$(cat /var/mysql/.mysql.root.pass) -sN);
do
	echo "optimize table $i;" | mysql -p$(cat /var/mysql/.mysql.root.pass) >/dev/null 2>&1
done
