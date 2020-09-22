# DB Restore CronJob

The Dockerfile in this directory retrieves `PostgreSQL` the latest backup dump file in a given Amazon S3 bucket (under the `BUCKET/backups` path), runs a local psql server and tests that the db restore works. To use it, create a `CronJob` with the following environment variables:

- `TARGET_DB_USER`: The name of the user who owns the backed-up database (needed because the dump file specifies it).
- The following variables are needed just for the postgres setup, supply them with the following values: 
    - `POSTGRES_USER`: With value `postgres`
    - `POSTGRES_PASSOWRD`: With value `postgres`
    - `POSTGRES_DB`: With value `test_db`
    - `PGDATA`: With value `/postgres/data`
- `SLACK_WEBHOOK_URL`: URL to send slack notifications on failure only.
- `TABLE_NAMES`: The names of the database tables, to check that they are present after restoring it.

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