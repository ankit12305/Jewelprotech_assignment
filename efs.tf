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

resource "aws_efs_mount_target" "efs_mount_target" {
  file_system_id  = aws_efs_file_system.my_efs.id
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.efs_sg.id]
}