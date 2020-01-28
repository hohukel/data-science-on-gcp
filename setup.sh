#!/bin/bash
source export-env.sh

SQL_STATUS=$(gcloud sql instances describe $INSTANCE_NAME | grep state | cut -d' ' -f 2)
if [ "$SQL_STATUS" != "RUNNABLE" ]; then
  echo "CloudSQLインスタンス起動中..."
  gcloud sql instances patch $INSTANCE_NAME --activation-policy ALWAYS
  while :
  do
    SQL_STATUS=$(gcloud sql instances describe $INSTANCE_NAME | grep state | cut -d' ' -f 2)
    if [ "$SQL_STATUS" = "RUNNABLE" ]; then
      echo "起動完了..."
      break
    fi
  done
else
  echo "CloudSQLインスタンスはすでに起動中"
fi

export MYSQLIP=$(gcloud sql instances describe $INSTANCE_NAME --format "value(ipAddresses.ipAddress)")
