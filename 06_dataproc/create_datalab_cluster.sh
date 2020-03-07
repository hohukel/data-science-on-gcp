#!/bin/bash

source ../export-env.sh
SETUP=gs://$BUCKET/flights/dataproc/setup_cluster.sh

echo "PROJECT=$PROJECT"
echo "BUCKET=$BUCKET"
echo "REGION=$REGION"
echo "ZONE=$ZONE"
echo "DATA_PROC_CLUSTER=$DATA_PROC_CLUSTER"
echo "CONDA_ENV_NAME=$CONDA_ENV_NAME"

echo "Upload install file"
sed "s/CHANGE_TO_USER_NAME/$USER/g" setup_cluster.sh > /tmp/setup_cluster.sh
gsutil cp /tmp/setup_cluster.sh $SETUP

echo "Create cluster"
gcloud dataproc clusters create $DATA_PROC_CLUSTER \
    --project $PROJECT \
    --region $REGION \
    --zone $ZONE \
    --num-workers=2 \
    --master-machine-type=n1-standard-2 \
    --worker-machine-type=n1-standard-2 \
    --master-boot-disk-size=15GB \
    --worker-boot-disk-size=15GB \
    --scopes cloud-platform \
    --initialization-actions $SETUP,gs://goog-dataproc-initialization-actions-${REGION}/datalab/datalab.sh
