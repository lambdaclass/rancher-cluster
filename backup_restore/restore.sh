set -eu -o pipefail
log_to_slack() {
    curl -X POST -H 'Content-type: application/json' --data "{'text':'${1}'}" "$SLACK_WEBHOOK_URL"
}
# This function will run if any of the commands fail.
on_fail() {
    log_to_slack "Backup restore failed!"
}
trap 'on_fail' ERR
sudo mkdir -p /postgres/data
sudo chown -R postgres /postgres
sudo -u postgres -E initdb -D /postgres/data
sudo -u postgres -E pg_ctl start
sudo -u postgres -E createdb test_db
sudo -u postgres -E createuser $TARGET_DB_USER

# OBJECT is the latest file in the bucket (i.e the latest backup)
# Taken from https://stackoverflow.com/questions/38384879/downloading-the-latest-file-in-an-s3-bucket-using-aws-cli
OBJECT="$(aws s3 ls $S3_BUCKET/backups --recursive | sort | tail -n 1 | awk '{print $4}')"
aws s3 cp s3://$S3_BUCKET/$OBJECT /etc/db.dump

psql -U $TARGET_DB_USER test_db < /etc/db.dump

# psql test commands
for table_name in $TABLE_NAMES
do
psql -h localhost -U $TARGET_DB_USER test_db -c "SELECT * FROM $table_name;"
done
