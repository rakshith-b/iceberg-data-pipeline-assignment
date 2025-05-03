output "rds_endpoint" {
  value = aws_db_instance.metastore.endpoint
}

output "rds_username" {
  value = aws_db_instance.metastore.username
}

output "rds_db_name" {
  value = aws_db_instance.metastore.db_name
}
