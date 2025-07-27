# e.g., in your `ecr.tf` file
resource "aws_ecr_repository" "my_app_repo" {
  name                 = "my-app-repo"
  image_tag_mutability = "MUTABLE" # Or IMMUTABLE based on your needs

  image_scanning_configuration {
    scan_on_push = true # Enable vulnerability scanning
  }

  tags = {
    Name = "my-app-repo"
  }
}
