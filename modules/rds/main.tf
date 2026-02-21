resource "aws_db_instance" "rds_postgresql" {
  identifier     = "athlon-alpha-rds-postgresql-${var.environment}"
  engine         = "postgres"
  engine_version = "17.6"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "athlon"
  username = var.db_username
  password = var.db_password

  publicly_accessible = false
  multi_az            = false

  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = var.subnet_group_name

  skip_final_snapshot = true
}
