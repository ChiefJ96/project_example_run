resource "aws_db_subnet_group" "default" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "rds-subnet-group"
  })
}

resource "aws_db_instance" "default" {
  identifier              = "rds-instance"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  allocated_storage       = 20
  db_name                 = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = var.security_group_ids
  multi_az                = var.multi_az
  skip_final_snapshot     = true
  deletion_protection     = false
  publicly_accessible     = false

  tags = merge(var.tags, {
    Name = "rds-instance"
  })
}