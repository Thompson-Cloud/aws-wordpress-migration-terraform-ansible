#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <aws-region> <migration-bucket>"
  exit 1
fi

AWS_REGION="$1"
MIGRATION_BUCKET="$2"

WORDPRESS_FILES_KEY="wordpress-files.tar.gz"
DATABASE_BACKUP_KEY="wordpress.sql"

echo "Validating migration bucket: ${MIGRATION_BUCKET}"

aws s3api head-bucket \
  --bucket "${MIGRATION_BUCKET}" \
  --region "${AWS_REGION}"

echo "Checking WordPress filesystem artifact..."

aws s3api head-object \
  --bucket "${MIGRATION_BUCKET}" \
  --key "${WORDPRESS_FILES_KEY}" \
  --region "${AWS_REGION}" \
  >/dev/null

echo "Checking database backup artifact..."

aws s3api head-object \
  --bucket "${MIGRATION_BUCKET}" \
  --key "${DATABASE_BACKUP_KEY}" \
  --region "${AWS_REGION}" \
  >/dev/null

echo "Migration artifacts validated successfully."
