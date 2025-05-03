provider "aws" {
  region = var.region
}

resource "aws_db_subnet_group" "metastore" {
  name       = "metastore-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "metastore-subnet-group"
  }
}

resource "aws_db_instance" "metastore" {
  identifier              = "hive-metastore-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  storage_encrypted       = true
  db_subnet_group_name    = aws_db_subnet_group.metastore.name
  vpc_security_group_ids  = var.vpc_security_group_ids

  tags = {
    Name = "hive-metastore"
    Environment = "dev"
  }
}
