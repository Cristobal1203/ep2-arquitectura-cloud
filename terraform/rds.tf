resource "aws_db_subnet_group" "rds_subnets" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = [aws_subnet.private_data_1a.id, aws_subnet.private_data_1b.id]

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier              = "${var.project_name}-mysql-ep2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t4g.small"
  allocated_storage       = 20
  storage_type            = "gp2"
  storage_encrypted       = true

  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password

  multi_az                = true
  db_subnet_group_name    = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  publicly_accessible     = false

  backup_retention_period = 7
  skip_final_snapshot     = true
  monitoring_interval     = 0

  tags = {
    Name = "${var.project_name}-rds-mysql-multiaz"
  }
}