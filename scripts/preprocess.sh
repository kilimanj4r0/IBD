#!/bin/bash
echo "Install git lfs"
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash
sudo yum install git-lfs
git lfs install

echo "Fetch data from git lfs"
git lfs fetch --all
git lfs checkout