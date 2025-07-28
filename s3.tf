# s3.tf

# 18. S3 Bucket for Static Files
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-app-static-files-${random_string.bucket_suffix.result}" # Globally unique name
  

  tags = {
    Name = "my-app-static-bucket"
  }
}

resource "aws_s3_bucket_acl" "app_bucket_acl" {
  bucket = aws_s3_bucket.app_bucket.id # Reference the ID of the bucket created above
  acl    = "private" # Set the desired ACL here, e.g., "private", "public-read"
}

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id # Reference the ID of the bucket created above

  versioning_configuration {
    status = "Enabled" # Use "Enabled" or "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "app_bucket_public_access_block" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
