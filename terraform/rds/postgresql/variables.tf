variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "db_identifier" {
  description = "RDS DB instance identifier"
  type        = string
  default     = "database-1"
}

variable "instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "metastore"
}

variable "db_username" {
  description = "Master DB username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master DB password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups for the DB"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "RDS DB subnet group name"
  type        = string
}

variable "availability_zone" {
  description = "AWS availability zone"
  type        = string
}