# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
# assetrack
# assetrack

## Production photo storage

Production uses durable S3 object storage for Active Storage uploads. Configure
these environment variables before deploying:

```text
ACTIVE_STORAGE_SERVICE=amazon
S3_ACCESS_KEY_ID=...
S3_SECRET_ACCESS_KEY=...
S3_REGION=...
S3_BUCKET=...
```

For an S3-compatible provider such as Cloudflare R2, use:

```text
ACTIVE_STORAGE_SERVICE=s3_compatible
S3_ACCESS_KEY_ID=...
S3_SECRET_ACCESS_KEY=...
S3_REGION=auto
S3_BUCKET=...
S3_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com
S3_FORCE_PATH_STYLE=false
```

Do not use the `local` service on hosts with ephemeral filesystems. Database
backups do not include uploaded files; back up the object-storage bucket too.
