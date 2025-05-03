#!/bin/bash
set -e

LOCAL_DIR="/home/rakshith/DE Iceberg Take-Home Assignment/iceberg-data-pipeline/scripts/logs/"
S3_BUCKET="s3://iceberg-pipeline-760561616948-us-west-2/logs"

echo "Uploading log files from $LOCAL_DIR to $S3_BUCKET ..."
aws s3 cp "$LOCAL_DIR" "$S3_BUCKET" --recursive
echo "Upload complete."
