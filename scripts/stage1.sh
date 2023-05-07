#!/bin/bash
echo "Creating DB"
rm -rf output/psql_results.txt
psql -U postgres -c 'DROP DATABASE IF EXISTS project;' >> output/psql_results.txt
psql -U postgres -c 'CREATE DATABASE project;' >> output/psql_results.txt
psql -U postgres -d project -f sql/db.sql >> output/psql_results.txt

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
