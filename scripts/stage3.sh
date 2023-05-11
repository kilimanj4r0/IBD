#!/bin/bash
echo "Run Predictive Data Analysis via spark-submit"
spark-submit --jars /usr/hdp/current/hive-client/lib/hive-metastore-1.2.1000.2.6.5.0-292.jar,/usr/hdp/current/hive-client/lib/hive-exec-1.2.1000.2.6.5.0-292.jar \
--packages org.apache.spark:spark-avro_2.12:3.0.3 \
scripts/pda.py

echo "Get trained models"
rm -rf models/*
hdfs dfs -get /root/IBD/models/ .

echo "Save model predictions"
rm -rf output/pred
mkdir output/pred

hdfs dfs -get /root/IBD/output/dt_predictions.csv output/pred
hdfs dfs -get /root/IBD/output/plr_predictions.csv output/pred

cat output/pred/dt_predictions.csv/* > output/pred/dt_pred.csv
cat output/pred/plr_predictions.csv/* > output/pred/plr_pred.csv

rm -rf output/pred/dt_predictions.csv output/pred/plr_predictions.csv