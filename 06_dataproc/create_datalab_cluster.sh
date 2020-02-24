#!/bin/bash

source ../export-env.sh
INSTALL=gs://$BUCKET/flights/dataproc/install_on_cluster.sh

echo "PROJECT=$PROJECT"
echo "BUCKET=$BUCKET"
echo "REGION=$REGION"
echo "ZONE=$ZONE"
echo "DATA_PROC_CLUSTER=$DATA_PROC_CLUSTER"
echo "DATALAB_INIT"=gs://dataproc-initialization-actions/datalab/datalab.sh

echo "Upload install file"
sed "s/CHANGE_TO_USER_NAME/$USER/g" install_on_cluster.sh > /tmp/install_on_cluster.sh
gsutil cp /tmp/install_on_cluster.sh $INSTALL

echo "Create cluster"
#gcloud dataproc clusters create $DATA_PROC_CLUSTER \
    #--region $REGION \
    #--zone=$ZONE \
    #--num-workers=2 \
    #--worker-machine-type=n1-standard-2 \
    #--master-machine-type=n1-standard-2 \
    #--metadata 'CONDA_PACKAGES="python==3.5"' \
    #--scopes cloud-platform \
    #--initialization-actions gs://goog-dataproc-initialization-actions-${REGION}/conda/bootstrap-conda.sh,gs://goog-dataproc-initialization-actions-${REGION}/conda/install-conda-env.sh,gs://goog-dataproc-initialization-actions-${REGION}/datalab/datalab.sh,$INSTALL

gcloud dataproc clusters create $DATA_PROC_CLUSTER \
    --project $PROJECT \
    --region $REGION \
    --zone $ZONE \
    --num-workers=2 \
    --worker-machine-type=n1-standard-2 \
    --master-machine-type=n1-standard-2 \
    --initialization-actions \
        gs://dataproc-initialization-actions/datalab/datalab.sh,$INSTALL
