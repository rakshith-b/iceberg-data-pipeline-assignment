# Scaling and Performance Metrics

This document describes the scalability assumptions and performance benchmarks for the Apache Iceberg Data Engineering Pipeline.

---

## ✅ Infrastructure Configuration

| Component            | Configuration                          |
|----------------------|------------------------------------------|
| EKS Cluster          | 1 control plane + 3 worker nodes         |
| Node Instance Type   | t3.large (2 vCPU, 8 GiB RAM)             |
| Storage              | Amazon S3 (scalable)                    |
| Table Format         | Apache Iceberg                          |
| Metadata Catalog     | Hive Metastore on Amazon RDS (MySQL)    |
| Spark Parallelism    | 3 to 6 tasks (based on node vCPUs)       |

---

## 📈 Throughput Estimate

| Metric                     | Estimate                             |
|----------------------------|--------------------------------------|
| Log lines per minute       | ~150,000–200,000 (whole cluster)     |
| Data processed per minute  | ~300–400 MB                          |
| ETL job latency            | ~1–2 minutes per batch               |

> These estimates are based on tests using the NASA web logs and PySpark with regex extraction and Iceberg write operations.

---

## 📊 Performance Monitoring Tools

- **Spark UI**: Stage/task duration, shuffle metrics
- **Prometheus + Grafana**: Executor CPU/RAM usage, job latency
- **Iceberg Metadata**: Track partition/file growth
- **S3 Logs**: Measure I/O throughput

---

## 🚀 Scaling Strategy

| Need                        | Scaling Solution                                |
|-----------------------------|-------------------------------------------------|
| Higher log ingestion        | Add Spark nodes/executors (horizontal scaling)  |
| Lower query latency         | Partition tuning + caching (Presto, Trino)      |
| Concurrency for analytics   | Use Spark Job Scheduling, K8s resource quotas   |
| Data > 1TB                  | Iceberg scales linearly with partition pruning  |

---

## 📘 Notes

- Horizontal scaling is preferred for log processing workloads.
- Use instance types like `m5.xlarge` or `r5.2xlarge` for higher memory scenarios.
