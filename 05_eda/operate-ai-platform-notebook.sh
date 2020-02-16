INSTANCE=pookoyakazan-test
gcloud compute ssh --project "pokoyakazan-test-01" --zone "us-west1-b" \
  $INSTANCE -- -L 8080:localhost:8080
