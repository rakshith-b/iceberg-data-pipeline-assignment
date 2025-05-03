variable "region" {
  type    = string
  default = "us-west-2"
}

variable "db_name" {
  type    = string
  default = "metastore"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type    = string
  sensitive = true
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}
