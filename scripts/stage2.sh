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

echo "Making EDA requests"
hive -f sql/eda.hql

echo "Saving EDA to csv"
rm -rf output/eda
mkdir output/eda

echo "category_code,avg_funding_m,funding_count" > output/eda/q1.csv
cat output/q1/* >> output/eda/q1.csv

echo "country_code,avg_funding_m,funding_count" > output/eda/q2.csv
cat output/q2/* >> output/eda/q2.csv

echo "company_id,employees,funding_total_usd" > output/eda/q3.csv
cat output/q3/* >> output/eda/q3.csv

echo "degree_type,avg_degree_fundings" > output/eda/q4.csv
cat output/q4/* >> output/eda/q4.csv

echo "year,sum_raised" > output/eda/q5.csv
cat output/q5/* >> output/eda/q5.csv

rm -rf output/q*/
