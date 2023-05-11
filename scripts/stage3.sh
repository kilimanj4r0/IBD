#!/bin/bash
echo "Please go to Zeppelin (http://localhost:9995), import notebook by link https://raw.githubusercontent.com/kilimanj4r0/IBD/main/notebooks/pda.json and start all cells"

read -p "Press enter to continue"

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