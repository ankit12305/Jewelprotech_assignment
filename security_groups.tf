# security_groups.tf

# 6. Security Group for ECS Instances (Worker Nodes)
resource "aws_security_group" "ecs_instance_sg" {
  name        = "ecs-instance-sg"
  description = "Allow inbound traffic for ECS instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all protocols from internal VPC for simplicity
    cidr_blocks = [var.vpc_cidr_block] # Allow from within VPC
  }

  ingress { # SSH access
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be more restrictive in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ecs-instance-sg"
  }
}

# 7. Security Group for ECS Service/Tasks (Application Load Balancer SG if used, or direct access SG)
# For simplicity, we'll allow HTTP from anywhere. In a real scenario, this would likely be an ALB SG.
resource "aws_security_group" "app_sg" {
  name        = "my-app-sg"
  description = "Allow inbound HTTP traffic to the application"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "my-app-sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow inbound access to RDS from ECS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.rds_port # MariaDB default port
    to_port         = var.rds_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_instance_sg.id, aws_security_group.app_sg.id] # Allow from ECS instances and app SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "rds-sg"
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Allow inbound access to EFS from ECS instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 2049 # NFS port
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_instance_sg.id] # Allow from ECS instances
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "efs-sg"
  }
}