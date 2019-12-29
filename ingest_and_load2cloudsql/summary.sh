INSTANCE_NAME=flights-instance
IP=$(curl http://ipecho.net/plain)

echo "create instance $INSTANCE_NAME"
gcloud sql instances create $INSTANCE_NAME \
--tier=db-n1-standard-1 --activation-policy=ALWAYS
echo "done"

echo "MySQLのアクセス制御 only allow access from $IP"
gcloud sql instances patch $INSTANCE_NAME \
--authorized-networks $IP
echo "done"

MYSQLIP=$(gcloud sql instances describe $INSTANCE_NAME --format "value(ipAddresses.ipAddress)")

echo "create database and table"
mysql --host=$MYSQLIP --user=root --password --verbose < create_table.sql
echo "done"

GCS_BUCKET=gs://pokoyakazan-test-01
GCS_DIR=flights/raw
# SERVICE_ACCONT_EMAIL=pokoyakazan-cloud-sql@pokoyakazan-test-01.iam.gserviceaccount.com:W gs://pokoyakazan-test-01
SERVICE_ACCONT_EMAIL=p58633301532-qygbxd@gcp-sa-cloud-sql.iam.gserviceaccount.com
gsutil acl ch -u $SERVICE_ACCONT_EMAIL:W gs://pokoyakazan-test-01
yes | for m in `seq -w 1 12`;do
  FILE=2015$m.csv
  DATA_LOCATION=$GCS_BUCKET/$GCS_DIR/$FILE
  gsutil acl ch -u $SERVICE_ACCONT_EMAIL:R $DATA_LOCATION
  echo "upload $FILE"
  gcloud sql import csv $INSTANCE_NAME $DATA_LOCATION --database=bts --table=flights
done
