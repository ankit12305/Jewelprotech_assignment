# ecs.tf

# 10. ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-app-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# NEW: 11. Launch Template for EC2 Instances (ECS Worker Nodes)
# This replaces the deprecated aws_launch_configuration.
resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "ecs-launch-template-"
  image_id      = var.ecs_ami_id # IMPORTANT: Ensure this is a valid ECS-optimized AMI for your region (us-east-1)
  instance_type = var.ecs_instance_type
  key_name      = demo-eks-key # Optional: If you use an SSH key for access, ensure this var is defined

  # Assign IAM Instance Profile to instances launched by this template
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  # Network configuration for instances launched by this template
  network_interfaces {
    associate_public_ip_address = true # Based on your previous launch_configuration setting
    delete_on_termination       = true # Good practice: ENI terminates with instance
    security_groups             = [aws_security_group.ecs_instance_sg.id]
  }

  # User Data for ECS Agent Configuration (base64-encoded script)
  # This uses a separate file for user_data for better readability.
  user_data = base64encode(templatefile("${path.module}/ecs_user_data.sh", {
    ecs_cluster_name = aws_ecs_cluster.my_cluster.name
  }))

  # Tags applied to the EC2 instances themselves
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-worker-node"
    }
  }

  # Tags applied to the Launch Template resource itself
  tags = {
    Name = "ecs-launch-template"
  }

  lifecycle {
    create_before_destroy = true
  }
}


# 12. Auto Scaling Group for ECS Instances
resource "aws_autoscaling_group" "ecs_asg" {
  name                 = "ecs-asg"
  vpc_zone_identifier  = [aws_subnet.public_1.id, aws_subnet.public_2.id] # Ensure these subnets are correctly defined and public

  # NEW: Reference the Launch Template instead of Launch Configuration
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest" # Always use the latest version of the template
  }

  min_size         = var.ecs_min_size
  max_size         = var.ecs_max_size
  desired_capacity = var.ecs_desired_count

  # Tags for the Auto Scaling Group resource itself
  tag {
    key                 = "Name"
    value               = "ecs-asg-group"
    propagate_at_launch = false # Do not propagate this ASG tag to instances, as instance tags are in the LT
  }

  # This tag is important for ECS auto-discovery of instances
  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true # Propagate this tag to instances
  }
}

# 13. ECR Repository (for our Docker image)
resource "aws_ecr_repository" "app_repo" {
  name                 = "my-app-repo"
  image_tag_mutability = "MUTABLE" # or IMMUTABLE
  image_scanning_configuration {
    scan_on_push = true
  }
}

# 14. ECS Task Definition
resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-app-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge" # Or 'awsvpc' if you want each task to get its own ENI

  cpu              = "256"
  memory           = "512"
  task_role_arn    = aws_iam_role.ecs_task_execution_role.arn # Optional, depends on task needs
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn # Mandatory for EC2 launch type for logging/image pull

  container_definitions = jsonencode([
    {
      name        = "my-app-container",
      image       = "${aws_ecr_repository.app_repo.repository_url}:latest", # Use ECR URL
      memory      = 512,
      cpu         = 256,
      essential   = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80 # Maps container port 80 to host port 80
        }
      ],
      environment = [ # Example of injecting environment variables from GitHub Secrets later
        {
          name  = "DB_HOST",
          value = aws_db_instance.db.address
        },
        {
          name  = "S3_BUCKET_NAME",
          value = aws_s3_bucket.app_bucket.id
        },
        # Add more environment variables here, potentially from GitHub Secrets via CI/CD
        # {
        #   name  = "DB_USER",
        #   value = "admin" # Potentially from GitHub Secrets
        # },
        # {
        #   name  = "DB_PASSWORD",
        #   value = "password" # Potentially from GitHub Secrets
        # }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name,
          "awslogs-region"        = var.region, # Ensure var.region is defined in variables.tf
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# 15. CloudWatch Log Group for ECS Tasks
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/my-app-task"
  retention_in_days = var.log_retention_days # Ensure var.log_retention_days is defined in variables.tf
}

# 16. Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "my-app-alb" # Choose a unique name
  internal           = false        # Set to true for internal-only ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_sg.id] # SG for the ALB, allowing inbound traffic on listener ports
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id] # Place ALB in public subnets

  # Optional: Enable deletion protection for production
  enable_deletion_protection = true # Set to false for easier teardown in dev/test

  tags = {
    Name = "my-app-alb"
  }
}

# 17. ALB Target Group
resource "aws_lb_target_group" "app_tg" {
  name        = "my-app-tg" # Choose a unique name for your target group
  port        = 80          # The port your container listens on
  protocol    = "HTTP"      # Or HTTPS if your tasks handle SSL
  vpc_id      = aws_vpc.main.id # Reference your VPC ID
  target_type = "instance"    # For EC2 launch type in ECS

  health_check {
    path                = "/" # Path for health checks (e.g., /health)
    protocol            = "HTTP"
    matcher             = "200" # HTTP status code for healthy
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "my-app-target-group"
  }
}

# 18. Define the Listener for the ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn # Reference the ALB's ARN
  port              = 80
  protocol          = "HTTP" # Or HTTPS if you're terminating SSL at the ALB

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn # Reference the target group ARN
  }

  tags = {
    Name = "my-app-http-listener"
  }
}


# 19. ECS Service
resource "aws_ecs_service" "my_service" {
  name            = "my-app-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "EC2"

  # Load balancer configuration for the ECS service
  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "my-app-container"
    container_port   = 80
  }

  network_configuration {
    # Use private subnets here if your tasks need private network access to RDS etc.
    subnets          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_groups  = [aws_security_group.app_sg.id]
    assign_public_ip = false # Tasks should not have public IPs if behind an ALB in private subnets
  }

  depends_on = [
    aws_autoscaling_group.ecs_asg, # Ensure ASG is up before service tries to place tasks
    aws_iam_role_policy_attachment.ecs_task_execution_policy, # Ensure execution role is attached
    aws_lb_listener.http_listener, # Ensure ALB listener is ready
  ]
}
