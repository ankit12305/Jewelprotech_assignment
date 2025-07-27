# main.tf

provider "aws" {
  region = "us-east-1"
}

# No other resources directly in main.tf; they are imported from other files.
# You might place module calls here if you convert these resources into a module later.