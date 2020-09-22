#! /usr/bin/env bash
set -eu -o pipefail
FILENAME="$DUMP_FILENAME$(date '+%m_%d_%Y')"
log_to_slack() {
    curl -X POST -H 'Content-type: application/json' --data "{'text':'${1}'}" "$SLACK_WEBHOOK_URL"
}
# This function will run if any of the commands fail.
on_fail() {
    log_to_slack "Backup failed!"
}
trap 'on_fail' ERR
mkdir -p /postgres
pg_dump -h "$TARGET_DB_SERVICE" -U "$TARGET_DB_USER" -w "$TARGET_DB_NAME" -f "/postgres/$FILENAME.dump"
aws s3 cp "/postgres/$FILENAME.dump" "s3://$S3_BUCKET/backups/$FILENAME.dump"
log_to_slack "Successful backup of $TARGET_DB_NAME db"