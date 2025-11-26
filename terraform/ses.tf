# SES Email Configuration for product notifications
# Note: In LocalStack, emails are captured locally
# In production AWS, you'll need to verify the email address first

output "ses_email_address" {
  description = "Email address configured for SES notifications"
  value       = var.notification_email
}

output "ses_email_region" {
  description = "SES region"
  value       = var.aws_region
}
