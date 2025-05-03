#!/bin/bash
set -e

echo "=== Submitting Spark Job ==="
kubectl exec -it --namespace default iceberg-spark-worker-0 -- spark-submit \
  --master spark://iceberg-spark-master-svc:7077 \
  --packages org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.4.2,org.apache.hadoop:hadoop-aws:3.3.6,com.amazonaws:aws-java-sdk-bundle:1.12.540 \
  --conf spark.jars.ivy=/tmp/.ivy2 \
  --conf spark.executor.memory=4g \
  --conf spark.driver.memory=4g \
  --conf spark.executor.cores=2 \
  --conf spark.executor.instances=3 \
  --conf spark.hadoop.fs.s3.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
  --conf spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.DefaultAWSCredentialsProviderChain \
  --conf spark.hadoop.fs.s3a.path.style.access=true \
  --conf spark.sql.catalog.spark_catalog=org.apache.iceberg.spark.SparkSessionCatalog \
  --conf spark.sql.catalog.spark_catalog.type=hive \
  --conf spark.sql.catalog.spark_catalog.uri="thrift://hms-hive-metastore.default.svc.cluster.local:9083" \
  --conf spark.sql.catalog.spark_catalog.warehouse=s3://iceberg-pipeline-760561616948-us-west-2/warehouse \
  /tmp/transform_logs.py

kubectl exec -it --namespace default iceberg-spark-worker-0 -- spark-sql \
  --master spark://iceberg-spark-master-svc:7077 \
  --packages org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.4.2,org.apache.hadoop:hadoop-aws:3.3.6,com.amazonaws:aws-java-sdk-bundle:1.12.540 \
  --conf spark.jars.ivy=/tmp/.ivy2 \
  --conf spark.hadoop.fs.s3.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
  --conf spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.DefaultAWSCredentialsProviderChain \
  --conf spark.hadoop.fs.s3a.path.style.access=true \
  --conf spark.sql.catalog.spark_catalog=org.apache.iceberg.spark.SparkSessionCatalog \
  --conf spark.sql.catalog.spark_catalog.type=hive \
  --conf spark.sql.catalog.spark_catalog.uri="thrift://hms-hive-metastore.default.svc.cluster.local:9083" \
  --conf spark.sql.catalog.spark_catalog.warehouse=s3://iceberg-pipeline-760561616948-us-west-2/warehouse \
  -e "CREATE DATABASE IF NOT EXISTS test_db;"

echo "=== Storing Analytical Views ==="
kubectl exec -it --namespace default iceberg-spark-worker-0 -- spark-sql --master spark://iceberg-spark-master-svc:7077 \
  -e "CREATE OR REPLACE VIEW spark_catalog.analytics.daily_top_ips AS \
      SELECT ip, COUNT(*) AS request_count \
      FROM spark_catalog.logs.web_access \
      WHERE DATE(timestamp) = CURRENT_DATE() \
      GROUP BY ip ORDER BY request_count DESC LIMIT 5;"

kubectl exec -it --namespace default iceberg-spark-worker-0 -- spark-sql --master spark://iceberg-spark-master-svc:7077 \
  -e "CREATE OR REPLACE VIEW spark_catalog.analytics.weekly_top_devices AS \
      SELECT device_type, COUNT(*) AS request_count \
      FROM spark_catalog.logs.web_access \
      WHERE weekofyear(timestamp) = weekofyear(current_date) \
      GROUP BY device_type ORDER BY request_count DESC LIMIT 5;"
