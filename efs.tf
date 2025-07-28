# efs.tf

# 19. EFS (Elastic File System)
resource "aws_efs_file_system" "my_efs" {
  creation_token   = "my-app-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
  tags = {
    Name = "my-app-efs"
  }
}

# EFS Mount Target for Private Subnet 1
resource "aws_efs_mount_target" "efs_mount_target_1" {
  file_system_id  = aws_efs_file_system.my_efs.id
  # Use your first private subnet
  subnet_id       = aws_subnet.private_1.id
  security_groups = [aws_security_group.efs_sg.id]
}

# EFS Mount Target for Private Subnet 2
resource "aws_efs_mount_target" "efs_mount_target_2" {
  file_system_id  = aws_efs_file_system.my_efs.id
  # Use your second private subnet
  subnet_id       = aws_subnet.private_2.id
  security_groups = [aws_security_group.efs_sg.id]
}
