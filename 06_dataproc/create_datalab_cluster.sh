#!/bin/bash

source ../export-env.sh
INSTALL=gs://$BUCKET/flights/dataproc/install_on_cluster.sh

echo "PROJECT=$PROJECT"
echo "BUCKET=$BUCKET"
echo "REGION=$REGION"
echo "ZONE=$ZONE"
echo "DATALAB_INIT"=gs://dataproc-initialization-actions/datalab/datalab.sh

echo "Upload install file"
sed "s/CHANGE_TO_USER_NAME/$USER/g" install_on_cluster.sh > /tmp/install_on_cluster.sh
gsutil cp /tmp/install_on_cluster.sh $INSTALL

echo "Create cluster"
gcloud dataproc clusters create $DATA_PROC_CLUSTER \
  --region=$REGION \
  --num-workers=2 \
  --scopes=cloud-platform \
  --worker-machine-type=n1-standard-2 \
  --master-machine-type=n1-standard-2 \
  --zone=us-central1-a \
  --initialization-actions=$INSTALL,gs://goog-dataproc-initialization-actions-${REGION}/conda/bootstrap-conda.sh,gs://goog-dataproc-initialization-actions-${REGION}/conda/install-conda-env.sh,gs://goog-dataproc-initialization-actions-${REGION}/datalab/datalab.sh \
