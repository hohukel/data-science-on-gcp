#!/bin/bash
source ../export-env.sh

SQL_STATUS=$(gcloud sql instances describe $CLOUD_SQL_INSTANCE_NAME | grep state | cut -d' ' -f 2)
if [ "$SQL_STATUS" = "RUNNABLE" ]; then
  echo "CloudSQLインスタンス停止中..."
  gcloud sql instances patch $INSTANCE_NAME --activation-policy NEVER
fi

