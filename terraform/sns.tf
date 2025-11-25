# SNS Topic for product notifications
resource "aws_sns_topic" "product_notifications" {
  name = "${var.project_name}-product-notifications"

  tags = {
    Name        = "Product Notifications Topic"
    Environment = var.environment
  }
}

# SNS Topic Subscription - Email
resource "aws_sns_topic_subscription" "product_email" {
  topic_arn = aws_sns_topic.product_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email

  depends_on = [aws_sns_topic.product_notifications]
}


