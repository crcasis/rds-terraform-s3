terraform {
  backend "s3" {
    bucket         = "name_bucket"
    key            = "folder/te2-rds.tf"
    region         = "eu-west-1"
    encrypt        = true
  }
}



provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

resource "random_string" "db-password" {
  length  = 32
  upper   = true
  numeric  = true
  special = false
}
resource "aws_security_group" "sonarqube" {
  vpc_id      = var.vpc
  name        = var.security_group
  description = "Allow all inbound for Postgres sonarqube"
ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "sonarqube" {
  name       = "te-sonarqube"
  subnet_ids = [var.subnet_a,var.subnet_b]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "sonarqube" {
  identifier             = var.db_instance_id
  db_name                = var.db_name
  instance_class         = var.db_instance_type
  allocated_storage      = var.db_instance_storage
  engine                 = var.db_instance_engine
  engine_version         = var.db_instance_engine_version
  skip_final_snapshot    = var.db_instance_skip_final_snapshot
  publicly_accessible    = var.db_instance_publicly_accessible
  vpc_security_group_ids = [aws_security_group.sonarqube.id]
  username               = var.db_username
  password               = "{random_string.db-password.result}"
  db_subnet_group_name   = aws_db_subnet_group.sonarqube.name
}
