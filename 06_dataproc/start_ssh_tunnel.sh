#!/bin/bash

export HOSTNAME=ch6cluster-m
export PORT=1080
gcloud compute ssh ${HOSTNAME} \
    --project=${PROJECT} --zone=${ZONE}  -- \
    -D ${PORT} -N
#gcloud compute ssh --zone=$ZONE \
  #--ssh-flag="-D 1080" --ssh-flag="-N" --ssh-flag="-n" \
  #ch6cluster-m

