provider "aws" {
  region = var.region
}

resource "aws_db_instance" "metastore" {
  identifier              = var.db_identifier
  engine                  = "postgres"
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name
  port                    = 5432
  publicly_accessible     = true
  skip_final_snapshot     = true
  vpc_security_group_ids  = var.vpc_security_group_ids
  db_subnet_group_name    = var.db_subnet_group_name
  multi_az                = false
  availability_zone       = var.availability_zone
  storage_encrypted       = false
  backup_retention_period = 0
}