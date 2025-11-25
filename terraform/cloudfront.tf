# # CloudFront Distribution with Private S3 Access
# # Using Origin Access Identity (OAI) for secure private access

# # Origin Access Identity for CloudFront to access S3 privately
# resource "aws_cloudfront_origin_access_identity" "oai" {
#   comment = "OAI for ${var.project_name} S3 bucket access"
# }

# # S3 bucket policy to allow CloudFront OAI access
# resource "aws_s3_bucket_policy" "cloudfront_access" {
#   bucket = aws_s3_bucket.app.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "CloudFrontOAIAccess"
#         Effect = "Allow"
#         Principal = {
#           AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
#         }
#         Action   = "s3:GetObject"
#         Resource = "${aws_s3_bucket.app.arn}/*"
#       },
#       {
#         Sid    = "CloudFrontOAIListBucket"
#         Effect = "Allow"
#         Principal = {
#           AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
#         }
#         Action   = "s3:ListBucket"
#         Resource = aws_s3_bucket.app.arn
#       }
#     ]
#   })
# }

# # CloudFront Distribution with Legacy Cache Behavior
# resource "aws_cloudfront_distribution" "s3_distribution" {
#   enabled             = true
#   is_ipv6_enabled     = true
#   default_root_object = "index.html"
#   price_class         = "PriceClass_100"

#   origin {
#     domain_name = aws_s3_bucket.app.bucket_regional_domain_name
#     origin_id   = "S3Origin"

#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
#     }
#   }

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "S3Origin"

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#     compress               = true
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }

#   tags = {
#     Name        = "${var.project_name}-cloudfront"
#     Environment = var.environment
#   }
# }

