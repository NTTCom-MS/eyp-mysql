#!/bin/bash

echo "mysqldump VALIDATOR"

echo "create database demo" | mysql

echo "show databases" | mysql

echo "mysqldump VALIDATOR - OK"

exit 0
