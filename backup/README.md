# Backup CronJob

The Dockerfile in this directory is to run backups of a target database in your k8s cluster and store them in a given Amazon S3 bucket, on the path `BUCKET/backups/`. To use it, create a `CronJob` from it in the same namespace as the target `postgreSQL` database service, then supply the following environment variables:

- `TARGET_DB_SERVICE`: The name of the target psql service (needed to connect to it and run a `pg_dump`).
- `TARGET_DB_USER`: The name of the user who owns the database in question. This should be a configuration variable (probably passed as an env. variable) in the target database.
- `TARGET_DB_NAME`: The name of the database in question.
- `PGPASSWORD`: Target db's password.
- `SLACK_WEBHOOK_URL`: URL to send slack notifications on success/failure.
- `DUMP_FILENAME`: Name of the resulting .dump file. The full name will be this value plus the date when the backup was made.

Additionally, the cronjob needs the S3 bucket name, access key ID and access key secret. You can supply them as the environment variables `S3_BUCKET`, `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` or via a k8s secret, creating it from the following template:

```
apiVersion: v1
kind: Secret
metadata:
  name: aws-keys
  namespace: your_namespace
stringData:
  S3_BUCKET: your_bucket
  AWS_ACCESS_KEY_ID: your_access_key_id
  AWS_SECRET_ACCESS_KEY: your_secret_key
```