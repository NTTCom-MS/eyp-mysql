#!/bin/bash

echo "mysqldump VALIDATOR"

echo "create database demo" | mysql

echo "create database junk" | mysql

echo "show databases" | mysql

bash ./mysqldump_test/backupmysqldump.sh ./mysqldump_test/all_dbs_file_per_db.config

find /backup -type f

echo "mysqldump VALIDATOR - OK"

exit 0
