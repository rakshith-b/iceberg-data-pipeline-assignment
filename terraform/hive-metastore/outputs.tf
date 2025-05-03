output "hive_metastore_release_status" {
  value = helm_release.hive_metastore.status
}

output "hive_metastore_namespace" {
  value = var.namespace
}
