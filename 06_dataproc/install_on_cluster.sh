#!/bin/bash

set -exo pipefail
PROFILE_SCRIPT_PATH=/etc/profile.d/effective-python.sh


echo "alias python='/usr/bin/python3.5'" | tee -a "${PROFILE_SCRIPT_PATH}" /etc/environment /usr/lib/spark/conf/spark-env.sh /etc/*bashrc /etc/profile /etc/profile.d/spark_config.sh

echo "spark.executorEnv.PYTHONHASHSEED=0" >> /etc/spark/conf/spark-defaults.conf /etc/profile.d/spark_config.sh

echo "export PYSPARK_PYTHON=/usr/bin/python3.5" | tee -a "${PROFILE_SCRIPT_PATH}" /etc/environment /usr/lib/spark/conf/spark-env.sh /etc/*bashrc /etc/profile /etc/profile.d/spark_config.sh

# CloudSDK libraries are installed in system python
echo 'export CLOUDSDK_PYTHON=/usr/bin/python3.5' | tee -a "${PROFILE_SCRIPT_PATH}" /etc/environment /usr/lib/spark/conf/spark-env.sh /etc/*bashrc /etc/profile /etc/profile.d/spark_config.sh

source ${PROFILE_SCRIPT_PATH}
source /etc/environment
source /usr/lib/spark/conf/spark-env.sh
source /etc/*bashrc
source /etc/profile

# install Google Python client on all nodes
apt-get update
apt-get install -y python-pip
pip install --upgrade google-api-python-client

# git clone on Master
USER=CHANGE_TO_USER_NAME
ROLE=$(/usr/share/google/get_metadata_value attributes/dataproc-role)

if [[ "${ROLE}"=='MASTER' ]];then
  cd /home/$USER
  git clone https://github.com/hohukel/etl-on-gcp.git
fi


