Hi Team,

## Overview
I wanted to provide a clear summary of the technical decision to transition from using the Hive Metastore (Option 1) to using Apache Iceberg with a Hadoop catalog on object storage (S3) — as per Option 2 in the recommended Iceberg architecture patterns.

## Tried Helm Github repos
- https://github.com/getindata/hive-metastore/tree/main
- https://github.com/aws-samples/hive-emr-on-eks/tree/main/hive-metastore-chart

## Background
Initially, the plan was to use Hive Metastore to manage Iceberg table metadata on S3, leveraging its compatibility and Spark integration. However, after repeated deployment and debugging attempts, several critical issues were encountered that made this approach unsustainable.

## Evidence and Observations
- We are encountering issues while integrating our standalone Hive Metastore with the Spark cluster on EKS. Despite deploying the metastore via the official Helm chart and connecting it to an external MySQL or PostgreSQL instance, the Spark jobs are failing with Hive catalog integration.
- We are currently encountering issues with the standalone Hive Metastore (HMS) deployed via Helm on EKS. Despite successful pod deployment and port forwarding, we’re seeing failures when trying to interact with Hive via Spark SQL.
```bash
kubectl get pods -n default
NAME                                  READY   STATUS    RESTARTS   AGE
hms-hive-metastore-65d4944875-d6slp   1/1     Running   0          12h
iceberg-spark-master-0                1/1     Running   0          23h
iceberg-spark-worker-0                1/1     Running   0          23h
iceberg-spark-worker-1                1/1     Running   0          24h
iceberg-spark-worker-2                1/1     Running   0          23h
iceberg-spark-worker-3                1/1     Running   0          23h
iceberg-spark-worker-4                1/1     Running   0          23h

kubectl get svc -n default
NAME                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
hms-hive-metastore         ClusterIP   10.100.135.20   <none>        9083/TCP          12h
iceberg-spark-headless     ClusterIP   None            <none>        <none>            35h
iceberg-spark-master-svc   ClusterIP   10.100.89.189   <none>        7077/TCP,80/TCP   35h
kubernetes                 ClusterIP   10.100.0.1      <none>        443/TCP           43h
```

- Below is a summary of the key issues and logs observed:

## 🧩 Spark Cluster Error
```bash
org.apache.hadoop.hive.metastore.HiveMetaStore: Opening raw store with implementation class:org.apache.hadoop.hive.metastore.ObjectStore
...
org.apache.hadoop.hive.metastore.ObjectStore: Failed to get database hive.test_db, returning NoSuchObjectException
...
java.net.ConnectException: Call From hive-metastore-... to localhost:9000 failed on connection exception: java.net.ConnectException: Connection refused
```

## 📌 Root Cause Suspicion - 1:

Hive Metastore is attempting to connect to localhost:9000, which corresponds to HDFS NameNode. But since we do not have a live HDFS service running (we're working on S3-based or Iceberg-backed storage), this connection is being refused.

This results in failure to validate or create Hive databases such as test_db, global_temp.

## 🔍 Hive Metastore Logs (Helm Deployed)
```bash
WARN org.apache.hadoop.hive.metastore.ObjectStore: Failed to get database hive.test_db, returning NoSuchObjectException
...
ERROR org.apache.hadoop.hive.metastore.utils.MetaStoreUtils: Got exception: java.net.ConnectException: Call From hive-metastore-... to localhost:9000 failed
...
MetaException(message:Got exception: java.net.ConnectException Call From hive-metastore-... to localhost:9000 failed on connection exception: java.net.ConnectException: Connection refused
```

## 📌 Indications:

The Hive Metastore attempts to create or read metadata directories on HDFS, but HDFS is not reachable or not running, leading to Connection Refused.

This breaks the Spark job execution where HiveCatalog is needed for Iceberg table metadata operations.

## ❗ Key Issue -2
While executing a basic Hive SQL operation from Spark (e.g., CREATE DATABASE IF NOT EXISTS test_db;), we receive the following error:
```bash
MetaException: Got exception: java.net.ConnectException
Call From hms-hive-metastore-786db6c9df-kp9fr/172.31.0.95 to localhost:9000 failed on connection exception: java.net.ConnectException: Connection refused
This indicates the Hive Metastore is trying to connect to HDFS NameNode on localhost:9000, which doesn't exist in the container's context, leading to failure.
```

## 🔍 Root Cause - 2
Hive Metastore is configured with a default HDFS URI pointing to hdfs://localhost:9000, which is invalid inside the Kubernetes pod.

There is no accessible HDFS NameNode running at localhost:9000 within the HMS pod, and hence HMS cannot access or manage the metadata store paths.

## 📌 Suggested Fix
Update Hive Metastore's config (core-site.xml and hive-site.xml) to point to a valid file system (e.g., s3a://your-bucket/ if using S3, or a reachable HDFS endpoint).

```bash
<property>
  <name>fs.defaultFS</name>
  <value>s3a://iceberg-pipeline-760561616948-us-west-2/warehouse</value> 
</property>

<property>
  <name>hive.metastore.warehouse.dir</name>
  <value>s3a://iceberg-pipeline-760561616948-us-west-2/warehouse</value>
</property>
```

## ❓ Help Needed
Could you please help us:

- Make the Hive Metastore work with S3/Iceberg backend instead of assuming an HDFS at localhost:9000.

- Identify any Helm chart or hive-site.xml misconfigurations that might be defaulting to HDFS?

- Share a working Helm chart configuration or steps used internally to run Spark + Hive Metastore on S3 + Iceberg without Hadoop HDFS?

## Decision: Move to Iceberg with Hadoop Catalog on S3
Given these constraints, I adopted the more robust Option 2 approach:

- Iceberg is used with a Hadoop catalog directly backed by S3 object storage, eliminating Hive Metastore completely.

- Spark now manages table metadata directly through the Iceberg catalog.

- The pipeline now uses Iceberg-native Spark APIs for reliable ingestion, deduplication, and partitioning (e.g., PARTITIONED BY (days(timestamp))).

Added Benefits
- ✅ Simplified architecture: no Hive Metastore setup, monitoring, or maintenance.

- ✅ Native support for Iceberg’s features: schema evolution, partition evolution, hidden partitioning.

- ✅ Successful end-to-end ingestion pipeline with the following working steps:

Raw log parsing, filtering malformed entries

## Writing clean Iceberg tables to S3

Computing and exporting daily/weekly top analytics to S3 in CSV format

## Next Steps
I’m happy to demo the working pipeline and folder structure in S3 for both raw and derived datasets. The new pipeline is leaner, stable under Kubernetes, and avoids brittle Hive-related dependencies.


### Best regards,
Rakshith