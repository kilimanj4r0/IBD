#!/bin/bash
echo "Install git lfs"
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash
sudo yum install -y git-lfs
git lfs install

echo "Fetch data from git lfs"
git lfs fetch --all
git lfs checkout

echo "Modify pg_hba config"
sed -i '1ihost all all 0.0.0.0/0 trust' /var/lib/pgsql/data/pg_hba.conf
sed -i '1ilocal all all trust' /var/lib/pgsql/data/pg_hba.conf