# LocalStack Configuration
# Use this file for local development with LocalStack
provider "aws" {
  region = var.aws_region

  # LocalStack endpoint configuration
  endpoints {
    s3         = "http://localhost:4566"
    dynamodb   = "http://localhost:4566"
    lambda     = "http://localhost:4566"
    apigateway = "http://localhost:4566"
    iam        = "http://localhost:4566"
    logs       = "http://localhost:4566"
    cloudwatch = "http://localhost:4566"
    cloudfront = "http://localhost:4566"
    sts        = "http://localhost:4566"
    sns        = "http://localhost:4566"
  }

  # Skip AWS account ID validation for LocalStack
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # LocalStack uses fixed credentials
  access_key        = "test"
  secret_key        = "test"
  s3_use_path_style = true
  #profile = "localstack"

  default_tags {
    tags = {
      Project     = "Projet1-Serverless"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

