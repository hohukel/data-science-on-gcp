#!/bin/bash
set -exo pipefail

apt-get update
apt-get install -y python3-pip

pip3 install numpy
pip3 install google-api-python-client

ln -s /usr/bin/python3.5 /usr/local/bin/python

# git clone on Master
USER=CHANGE_TO_USER_NAME
ROLE=$(/usr/share/google/get_metadata_value attributes/dataproc-role)

if [[ "${ROLE}"=='MASTER' ]];then
  cd /home/$USER
  git clone https://github.com/hohukel/etl-on-gcp.git
fi


