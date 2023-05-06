#!/bin/bash
echo "Install git lfs and fetch data"
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash
sudo yum install git-lfs
git lfs install
git lfs fetch --all
git lfs checkout