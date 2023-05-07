#!/bin/bash
echo "Transfer avsc files to HDFS"
hdfs dfs -rm -r /project/avsc
hdfs dfs -mkdir /project/avsc
hdfs dfs -put data/*.avsc /project/avsc

echo "Transfer java files to HDFS"
hdfs dfs -rm -r /project/java
hdfs dfs -mkdir /project/java
hdfs dfs -put data/*.java /project/java

echo "Build HIVE tables"
hdfs dfs -chmod -R 777 /project
rm -rf output/hive_results.txt
hive -f sql/db.hql > output/hive_results.txt