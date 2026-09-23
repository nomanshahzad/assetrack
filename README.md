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

Photo capture and uploads are disabled by default. To show the photo controls,
saved photos, and PDF photo pages, set:

```text
PHOTOS_ENABLED=true
```

Leave this variable unset while the feature is not needed. Before enabling it
in production, configure durable storage as described below. While photos are
disabled, Rails uses local storage and no AWS or S3 environment variables are
required.

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
If `ACTIVE_STORAGE_SERVICE` is omitted, the app falls back to `local` so it can
boot, but uploads will not survive a restart on an ephemeral host.
