from pyspark.sql import SparkSession
from pyspark.sql.functions import regexp_extract, to_timestamp, col, when

spark = SparkSession.builder \
    .appName("ParseAndIngestLogs") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.iceberg.spark.SparkSessionCatalog") \
    .config("spark.sql.catalog.spark_catalog.type", "hive") \
    .config("spark.sql.catalog.spark_catalog.uri", "thrift://hms-hive-metastore.default.svc.cluster.local:9083") \
    .config("spark.sql.catalog.spark_catalog.warehouse", "s3://iceberg-pipeline-760561616948-us-west-2/warehouse") \
    .getOrCreate()

raw_logs = spark.read.text("s3://iceberg-pipeline-760561616948-us-west-2/logs/")

parsed_logs = raw_logs.select(
    regexp_extract('value', r'^(\S+)', 1).alias('ip'),
    regexp_extract('value', r'\[(.*?)\]', 1).alias('timestamp_raw'),
    regexp_extract('value', r'\"(GET|POST|PUT|DELETE)\\s(\\S+)', 2).alias('endpoint'),
    regexp_extract('value', r'\"\\s(\\d{3})\\s', 1).alias('status_code'),
    regexp_extract('value', r'\\s(\\d+)$', 1).alias('response_size')
)

valid_logs = parsed_logs.filter(
    col("ip").isNotNull() & col("timestamp_raw").isNotNull() & col("endpoint").isNotNull()
)

malformed_logs = parsed_logs.subtract(valid_logs)
malformed_logs.write.mode("overwrite").json("s3://iceberg-pipeline-760561616948-us-west-2/logs/malformed/")

valid_logs = valid_logs \
    .withColumn("timestamp", to_timestamp(col("timestamp_raw"), "dd/MMM/yyyy:HH:mm:ss Z")) \
    .withColumn("device_type", when(col("endpoint").like("%.js"), "browser")
                .when(col("endpoint").like("%.css"), "browser")
                .when(col("endpoint").like("%.jpg"), "image")
                .when(col("endpoint").like("%.png"), "image")
                .otherwise("unknown")) \
    .drop("timestamp_raw")

deduped_logs = valid_logs.dropDuplicates(["ip", "timestamp", "endpoint"])

# Ensure Hive database exists
spark.sql("CREATE DATABASE IF NOT EXISTS spark_catalog.logs")

# Create table explicitly using Iceberg syntax
spark.sql("""
CREATE TABLE IF NOT EXISTS spark_catalog.logs.web_access (
    ip STRING,
    timestamp TIMESTAMP,
    endpoint STRING,
    status_code STRING,
    response_size STRING,
    device_type STRING
)
USING iceberg
PARTITIONED BY (days(timestamp))
LOCATION 's3://iceberg-pipeline-760561616948-us-west-2/warehouse/logs/web_access'
""")
 
# Append data
deduped_logs.writeTo("spark_catalog.logs.web_access").append()

print("Data parsed, filtered, and written to Iceberg.")