#!/bin/bash

cd $(dirname $0)

RETURN=0

echo "mysqldump VALIDATOR"

echo "create database demo" | mysql

echo "create database junk" | mysql

echo "== DBS =="
echo "show databases" | mysql
echo ">><<"

bash -x ./mysqldump_test/backupmysqldump ./mysqldump_test/all_dbs_file_per_db_no_compression.config

find /mysql-backup -type f -iname \*demo\* -exec cat {} \; | grep demo
if [ $? -eq 0 ];
then
  echo "dump contains the expected DB - OK"
else
  echo "dump contains the expected DB - FAIL"
  RETURN=1
fi

find /mysql-backup -type f -iname \*demo\* -exec cat {} \; | grep junk
if [ $? -eq 0 ];
then
  echo "dump contains unexpected DBs - FAIL"
  RETURN=1
else
  echo "dump contains unexpected DBs - OK"
fi

if [ "${RETURN}" -eq  0 ];
then
  echo "mysqldump VALIDATOR - OK"
fi

exit $RETURN
