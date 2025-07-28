# outputs.tf

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}


output "public_subnet_id_1" {
  description = "The ID of the first public subnet"
  value       = aws_subnet.public_1.id
}

output "public_subnet_id_2" {
  description = "The ID of the second public subnet"
  value       = aws_subnet.public_2.id
}

output "private_subnet_id_1" {
  description = "The ID of the first private subnet"
  value       = aws_subnet.private_1.id
}

output "private_subnet_id_2" {
  description = "The ID of the second private subnet"
  value       = aws_subnet.private_2.id
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.my_cluster.name
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.db.address
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.app_bucket.id
}

output "efs_id" {
  description = "The ID of the EFS file system"
  value       = aws_efs_file_system.my_efs.id
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

#output "app_service_public_ip" {
#  description = "Public IP of the ECS service task (if assign_public_ip is true and not using ALB)"
#  #value       = one(aws_ecs_service.my_service.network_configuration[0].assign_public_ip) ? aws_ecs_service.my_service.load_balancer[0].target_group_arn : "N/A - Check if ALB is configured or if task has a public IP"
#  # Note: Getting the public IP of an ECS task directly without an ALB can be tricky and may require more complex logic or external data sources.
#  # This output is a placeholder; consider using an ALB and its DNS name for public access.
# }
