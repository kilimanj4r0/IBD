#!/bin/bash
echo "Creating DB"
psql -U postgres -c 'DROP DATABASE IF EXISTS project;'
psql -U postgres -c 'CREATE DATABASE project;'
psql -U postgres -d project -f sql/db.sql

echo "Creating a sqoop job and import all table into HDFS"
cd data
hdfs dfs -rm -r /project
sqoop import-all-tables \
    -Dmapreduce.job.classloader=true \
    -Dorg.apache.sqoop.splitter.allow_text_splitter=true \
    --connect jdbc:postgresql://localhost/project \
    --username postgres \
    --warehouse-dir /project \
    --as-avrodatafile
cd ../
