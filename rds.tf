# rds.tf

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "my-app-rds-subnet-group"
  description = "Subnet group for RDS DB instance"
  # Provide both private subnets here
  subnet_ids  = [aws_subnet.private_1.id, aws_subnet.private_2.id] # 

  tags = {
    Name = "my-app-rds-subnet-group"
  }
}

resource "aws_db_instance" "db" { 
  identifier            = "my-app-db"
  engine                = "mariadb"
  engine_version        = "10.6" # Specify a valid MariaDB version
  instance_class        = var.rds_instance_class
  allocated_storage     = var.rds_allocated_storage
  storage_type          = "gp2"
  db_name               = var.db_name
  username              = var.db_username
  password              = var.db_password # IMPORTANT: Use a strong, secret password!
  port                  = var.rds_port
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name  = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible   = false # For simplicity; ideally, keep private and access via ECS
  skip_final_snapshot   = true # For dev/test environments
  multi_az              = true
}
