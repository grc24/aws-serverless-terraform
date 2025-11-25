
resource "aws_lambda_function" "product_manager" {
  function_name    = var.lambdafunction_name
  filename         = var.lambda_zip_code
  source_code_hash = filebase64sha256("${var.lambda_zip_code}")
  handler          = "product_api.handler"
  runtime          = var.lambda_runtime
  role             = aws_iam_role.lambda_execution_role.arn
  publish          = true
  timeout          = 30

  environment {
    variables = {
      DYNAMODB_ENDPOINT = "http://localstack:4566"
      SNS_TOPIC_ARN     = aws_sns_topic.product_notifications.arn
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}
