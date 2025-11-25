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

# output "cloudfront_domain_name" {
#   description = "CloudFront distribution domain name for CDN access"
#   value       = aws_cloudfront_distribution.s3_distribution.domain_name
# }

# output "cloudfront_distribution_id" {
#   description = "CloudFront distribution ID for cache invalidation"
#   value       = aws_cloudfront_distribution.s3_distribution.id
# }

# output "origin_access_identity_arn" {
#   description = "CloudFront Origin Access Identity ARN"
#   value       = aws_cloudfront_origin_access_identity.oai.iam_arn
# }

# output "website_access_url" {
#   description = "URL to access the website"
#   value       = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
# }

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


# Output the SNS Topic ARN for Lambda to use
output "sns_topic_arn" {
  description = "SNS Topic ARN for product notifications"
  value       = aws_sns_topic.product_notifications.arn
}

output "notification_email" {
  description = "Email address subscribed to notifications"
  value       = var.notification_email
}