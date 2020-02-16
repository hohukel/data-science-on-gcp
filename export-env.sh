#export PROJECT=pokoyakazan-test-01
export PROJECT=$(gcloud config get-value project)
export BUCKET=pokoyakazan-test-01
export REGION=us-central1
export ZONE=us-central1-a
export INSTANCE_NAME=flights-instance
export IP=$(curl http://ipecho.net/plain)
