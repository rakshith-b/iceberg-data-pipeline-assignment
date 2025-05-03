from pyspark.sql import SparkSession
from pyspark.sql.functions import regexp_extract, to_timestamp, col, when, current_date, weekofyear

# Initialize SparkSession
spark = SparkSession.builder \
    .appName("ParseAndIngestLogs") \
    .config("spark.sql.catalog.hadoop_cat", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.hadoop_cat.type", "hadoop") \
    .config("spark.sql.catalog.hadoop_cat.warehouse", "s3://iceberg-pipeline-760561616948-us-west-2/warehouse") \
    .getOrCreate()

# Read raw logs
raw_logs = spark.read.text("s3://iceberg-pipeline-760561616948-us-west-2/logs/")

# Parse logs
parsed_logs = raw_logs.select(
    regexp_extract('value', r'^(\S+)', 1).alias('ip'),
    regexp_extract('value', r'\[(.*?)\]', 1).alias('timestamp_raw'),
    regexp_extract('value', r'\"(GET|POST|PUT|DELETE)\s(\S+)', 2).alias('endpoint'),
    regexp_extract('value', r'\"\s(\d{3})\s', 1).alias('status_code'),
    regexp_extract('value', r'\s(\d+)$', 1).alias('response_size')
)

# Filter valid logs
valid_logs = parsed_logs.filter(
    col("ip").isNotNull() & col("timestamp_raw").isNotNull() & col("endpoint").isNotNull()
)

# Save malformed logs
parsed_logs.subtract(valid_logs).write.mode("overwrite").json(
    "s3://iceberg-pipeline-760561616948-us-west-2/logs/malformed/"
)

# Clean and deduplicate
valid_logs = valid_logs \
    .withColumn("timestamp", to_timestamp(col("timestamp_raw"), "dd/MMM/yyyy:HH:mm:ss Z")) \
    .withColumn("device_type", when(col("endpoint").like("%.js"), "browser")
                .when(col("endpoint").like("%.css"), "browser")
                .when(col("endpoint").like("%.jpg"), "image")
                .when(col("endpoint").like("%.png"), "image")
                .otherwise("unknown")) \
    .drop("timestamp_raw")

deduped_logs = valid_logs.dropDuplicates(["ip", "timestamp", "endpoint"])

# Create Iceberg table and append
spark.sql("""
CREATE TABLE IF NOT EXISTS hadoop_cat.logs.web_access (
    ip STRING,
    timestamp TIMESTAMP,
    endpoint STRING,
    status_code STRING,
    response_size STRING,
    device_type STRING
)
PARTITIONED BY (days(timestamp))
STORED AS ICEBERG
""")

deduped_logs.writeTo("hadoop_cat.logs.web_access").append()

# ============================
# Compute Daily Top IPs
# ============================
from pyspark.sql.functions import date_format

web_access_df = spark.read.format("iceberg").load("hadoop_cat.logs.web_access")

daily_top_ips = web_access_df \
    .filter(date_format("timestamp", "yyyy-MM-dd") == date_format(current_date(), "yyyy-MM-dd")) \
    .groupBy("ip") \
    .count() \
    .orderBy(col("count").desc()) \
    .limit(5)

daily_top_ips.write.mode("overwrite").option("header", True).csv(
    "s3://iceberg-pipeline-760561616948-us-west-2/analytics_output/daily_top_ips"
)

# ============================
# Compute Weekly Top Devices
# ============================
weekly_top_devices = web_access_df \
    .filter(weekofyear(col("timestamp")) == weekofyear(current_date())) \
    .groupBy("device_type") \
    .count() \
    .orderBy(col("count").desc()) \
    .limit(5)

weekly_top_devices.write.mode("overwrite").option("header", True).csv(
    "s3://iceberg-pipeline-760561616948-us-west-2/analytics_output/weekly_top_devices"
)

print("Logs parsed, saved to Iceberg, and analytics results exported as CSV.")
