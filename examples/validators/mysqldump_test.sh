#!/bin/bash

cd $(dirname $0)

echo "mysqldump VALIDATOR"

echo "create database demo" | mysql

echo "create database junk" | mysql

echo "== DBS =="
echo "show databases" | mysql
echo ">><<"

bash -x ./mysqldump_test/backupmysqldump ./mysqldump_test/all_dbs_file_per_db_no_compression.config

find /mysql-backup -type f

echo "mysqldump VALIDATOR - OK"

exit 0
