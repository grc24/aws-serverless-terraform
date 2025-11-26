output "s3_bucket_name" {
  description = "S3 bucket name for static website"
  value       = aws_s3_bucket.app.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.app.arn
}

output "s3_website_endpoint" {
  description = "S3 website endpoint"
  value       = aws_s3_bucket_website_configuration.app.website_endpoint
}

output "s3_bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  value       = aws_s3_bucket.app.bucket_regional_domain_name
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = "https://${aws_api_gateway_rest_api.product_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}"
}

output "api_put_product_endpoint" {
  description = "API Gateway endpoint for PUT /products"
  value       = "https://${aws_api_gateway_rest_api.product_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/products"
}

output "api_get_products_endpoint" {
  description = "API Gateway endpoint for GET /products (list all)"
  value       = "https://${aws_api_gateway_rest_api.product_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/products"
}

output "api_get_product_endpoint" {
  description = "API Gateway endpoint for GET /products/{product_id}"
  value       = "https://${aws_api_gateway_rest_api.product_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/products/{product_id}"
}

output "api_delete_product_endpoint" {
  description = "API Gateway endpoint for DELETE /products/{product_id}"
  value       = "https://${aws_api_gateway_rest_api.product_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/products/{product_id}"
}

output "api_rest_api_id" {
  description = "REST API ID"
  value       = aws_api_gateway_rest_api.product_api.id
}

output "notification_email" {
  description = "Email address for SES notifications"
  value       = var.notification_email
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.product_manager.function_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.products.name
}
