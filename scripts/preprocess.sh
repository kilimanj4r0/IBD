#!/bin/bash
echo "Install git lfs and fetch data"
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash
sudo yum install git-lfs
git lfs install
git lfs fetch --all
git lfs checkout

echo "Creating DB"
psql -U postgres -c 'DROP DATABASE IF EXISTS project;'
psql -U postgres -c 'CREATE DATABASE project;'
psql -U postgres -d project -f sql/db.sql

