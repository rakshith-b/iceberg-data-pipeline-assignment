#!/bin/bash
set -e

echo "=== Submitting Spark Job ==="
kubectl exec -it --namespace default iceberg-spark-worker-0 -- spark-submit \
  --master spark://iceberg-spark-master-svc:7077 \
  --packages org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.4.2 \
  --conf spark.jars.ivy=/tmp/.ivy2 \
  --conf spark.executor.memory=4g \
  --conf spark.driver.memory=4g \
  --conf spark.executor.cores=2 \
  --conf spark.executor.instances=3 \
  --conf spark.hadoop.fs.s3.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
  --conf spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.DefaultAWSCredentialsProviderChain \
  --conf spark.hadoop.fs.s3a.path.style.access=true \
  --conf spark.sql.catalog.hadoop_cat=org.apache.iceberg.spark.SparkCatalog \
  --conf spark.sql.catalog.hadoop_cat.type=hadoop \
  --conf spark.sql.catalog.hadoop_cat.warehouse=s3://iceberg-pipeline-760561616948-us-west-2/warehouse \
  /tmp/transform_logs_hc.py