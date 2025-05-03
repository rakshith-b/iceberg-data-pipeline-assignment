output "spark_release_status" {
  value = helm_release.spark.status
}

output "spark_namespace" {
  value = helm_release.spark.namespace
}
