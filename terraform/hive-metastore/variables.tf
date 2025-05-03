variable "region" {
  type    = string
  default = "us-west-2"
}

variable "namespace" {
  type    = string
  default = "hive"
}

variable "rds_endpoint" {
  type        = string
  description = "RDS endpoint (hostname) for MySQL metastore"
}

variable "rds_port" {
  type    = number
  default = 3306
  description = "RDS port for MySQL metastore"
}

variable "rds_db_name" {
  type    = string
  default = "metastore"
}

variable "rds_username" {
  type    = string
  default = "admin"
}

variable "rds_password" {
  type    = string
  sensitive = true
}

variable "s3_warehouse_bucket" {
  type        = string
  description = "S3 bucket for Hive warehouse"
}

variable "service_type" {
  type    = string
  default = "ClusterIP"
  description = "Kubernetes service type for Hive Metastore (ClusterIP, LoadBalancer, etc.)"
}