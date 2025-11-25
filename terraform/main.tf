
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Disable remote state for LocalStack development
  # Uncomment the backend block when using real AWS
  backend "local" {
    path = "terraform.tfstate"
  }
  #  backend "s3" {
  #   bucket         = "development-state-lock-projet1-serverless"
  #   key            = "env:/terraform.tfstate"
  #   region         = "eu-west-3"
  #   encrypt        = false
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  #   skip_requesting_account_id  = true
  #   //use_lockfile = false
  # } 

}