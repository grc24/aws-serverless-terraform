variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "bucket_state" {
  description = "Existant bucket"
  type        = string
  default     = "state-lock-s3"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "projet1-serverless"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for products"
  type        = string
  default     = "products-catalog"
}

variable "read_capacity" {
  description = "DynamoDB read capacity units"
  type        = number
  default     = 100
}

variable "write_capacity" {
  description = "DynamoDB write capacity units"
  type        = number
  default     = 100
}

variable "lambdafunction_name" {
  description = "Name of the lambda function"
  type        = string
  default     = "product_api_function"
}

variable "lambda_runtime" {
  description = "Runtime Lambda"
  type        = string
  default     = "python3.8"
}

variable "lambda_zip_code" {
  description = "Lambda code"
  type        = string
  default     = "product_api.zip"
}

variable "notification_email" {
  description = "Email address for SNS notifications"
  type        = string
  default     = "awsdavid20@gmail.com"
}
