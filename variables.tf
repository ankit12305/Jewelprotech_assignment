# variables.tf

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for the public subnet"
  type        = string
  default     = "us-east-1a"
}

variable "ecs_instance_type" {
  description = "EC2 instance type for ECS worker nodes"
  type        = string
  default     = "t2.micro"
}

variable "ecs_ami_id" {
  description = "AMI ID for ECS-optimized instances (IMPORTANT: Replace with a valid AMI)"
  type        = string
  default     = "ami-0014001d539c943ac" # !!! REPLACE THIS WITH A VALID ECS OPTIMIZED AMI ID FOR us-east-1 !!!
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS instance (GB)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "mydb"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for the database (IMPORTANT: Use secrets management in production!)"
  type        = string
  sensitive   = true
  default     = "SecurePassword123!"
}

variable "rds_port" {
  description = "Port for the RDS instance"
  type        = number
  default     = 3306
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks for the service"
  type        = number
  default     = 1
}

variable "ecs_min_size" {
  description = "Minimum number of ECS instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "ecs_max_size" {
  description = "Maximum number of ECS instances in the Auto Scaling Group"
  type        = number
  default     = 2
}
