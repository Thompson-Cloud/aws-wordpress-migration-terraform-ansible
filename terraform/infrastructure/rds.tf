resource "aws_db_subnet_group" "wordpress" {
  name = "wordpress-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_db_a.id,
    aws_subnet.private_db_b.id
  ]

  tags = {
    Name = "wordpress-db-subnet-group"
  }
}

resource "aws_db_instance" "wordpress" {
  identifier = "wordpress-migration-db"

  engine = "mysql"

  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username

  manage_master_user_password = true

  db_subnet_group_name = aws_db_subnet_group.wordpress.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 1

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "wordpress-migration-rds"
  }
}