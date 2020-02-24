#!/bin/bash

set -exo pipefail
PROFILE_SCRIPT_PATH=/etc/profile.d/effective-python.sh

apt-get update

apt-get install -y build-essential checkinstall
apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
cd /usr/src
wget https://www.python.org/ftp/python/3.5.6/Python-3.5.6.tgz
tar xzf Python-3.5.6.tgz
cd Python-3.5.6
./configure --enable-optimizations
make altinstall
ln -s /usr/local/bin/python3.5 /usr/local/bin/python

/usr/local/bin/pip3.5 install numpy
/usr/local/bin/pip3.5 install google-api-python-client

echo "alias python='/usr/local/bin/python3.5'" | tee -a "${PROFILE_SCRIPT_PATH}" /etc/environment /usr/lib/spark/conf/spark-env.sh /etc/*bashrc /etc/profile /etc/profile.d/spark_config.sh

echo "spark.executorEnv.PYTHONHASHSEED=0" >> /etc/spark/conf/spark-defaults.conf /etc/profile.d/spark_config.sh

echo "export PYSPARK_PYTHON=/usr/local/bin/python3.5" | tee -a "${PROFILE_SCRIPT_PATH}" /etc/environment /usr/lib/spark/conf/spark-env.sh /etc/*bashrc /etc/profile /etc/profile.d/spark_config.sh

# CloudSDK libraries are installed in system python
echo 'export CLOUDSDK_PYTHON=/usr/local/bin/python3.5' | tee -a "${PROFILE_SCRIPT_PATH}" /etc/environment /usr/lib/spark/conf/spark-env.sh /etc/*bashrc /etc/profile /etc/profile.d/spark_config.sh

source ${PROFILE_SCRIPT_PATH}
source /etc/environment
source /usr/lib/spark/conf/spark-env.sh
source /etc/*bashrc
source /etc/profile

# git clone on Master
USER=CHANGE_TO_USER_NAME
ROLE=$(/usr/share/google/get_metadata_value attributes/dataproc-role)

if [[ "${ROLE}"=='MASTER' ]];then
  cd /home/$USER
  git clone https://github.com/hohukel/etl-on-gcp.git
fi


