# main.tf

provider "aws" {
  region = "us-east-1"
}

# No other resources directly in main.tf; they are imported from other files.
# You might place module calls here if you convert these resources into a module later.


terraform {
backend "s3" {
    bucket         = "terraform-state-file-myapp" # <--- IMPORTANT: Replace with a globally unique S3 bucket name
    key            = "my-app/terraform.tfstate"                 # Path to your state file within the bucket
    region         = "us-east-1"                                # Match your AWS_REGION
    encrypt        = true                                       # Encrypts the state file at rest
    dynamodb_table = "terraform-state-lock-table"   # <--- IMPORTANT: Replace with a unique DynamoDB table name for state locking
  }
}
