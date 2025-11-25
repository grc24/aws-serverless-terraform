# API Gateway for Product Management (REST API v1 - LocalStack Community compatible)
resource "aws_api_gateway_rest_api" "product_api" {
  name        = "${var.project_name}-api"
  description = "REST API for Product Management"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# /products resource
resource "aws_api_gateway_resource" "products" {
  rest_api_id = aws_api_gateway_rest_api.product_api.id
  parent_id   = aws_api_gateway_rest_api.product_api.root_resource_id
  path_part   = "products"
}

# /products/{product_id} resource
resource "aws_api_gateway_resource" "product" {
  rest_api_id = aws_api_gateway_rest_api.product_api.id
  parent_id   = aws_api_gateway_resource.products.id
  path_part   = "{product_id}"
}

# PUT /products - Create/Update product
resource "aws_api_gateway_method" "put_products" {
  rest_api_id      = aws_api_gateway_rest_api.product_api.id
  resource_id      = aws_api_gateway_resource.products.id
  http_method      = "PUT"
  authorization    = "NONE"
}

resource "aws_api_gateway_integration" "put_products_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.product_api.id
  resource_id             = aws_api_gateway_resource.products.id
  http_method             = aws_api_gateway_method.put_products.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.product_manager.invoke_arn
}

# GET /products - List all products
resource "aws_api_gateway_method" "get_products" {
  rest_api_id      = aws_api_gateway_rest_api.product_api.id
  resource_id      = aws_api_gateway_resource.products.id
  http_method      = "GET"
  authorization    = "NONE"
}

resource "aws_api_gateway_integration" "get_products_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.product_api.id
  resource_id             = aws_api_gateway_resource.products.id
  http_method             = aws_api_gateway_method.get_products.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.product_manager.invoke_arn
}

# GET /products/{product_id} - Get single product
resource "aws_api_gateway_method" "get_product" {
  rest_api_id      = aws_api_gateway_rest_api.product_api.id
  resource_id      = aws_api_gateway_resource.product.id
  http_method      = "GET"
  authorization    = "NONE"

  request_parameters = {
    "method.request.path.product_id" = true
  }
}

resource "aws_api_gateway_integration" "get_product_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.product_api.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = aws_api_gateway_method.get_product.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.product_manager.invoke_arn
}

# DELETE /products/{product_id} - Delete product
resource "aws_api_gateway_method" "delete_product" {
  rest_api_id      = aws_api_gateway_rest_api.product_api.id
  resource_id      = aws_api_gateway_resource.product.id
  http_method      = "DELETE"
  authorization    = "NONE"

  request_parameters = {
    "method.request.path.product_id" = true
  }
}

resource "aws_api_gateway_integration" "delete_product_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.product_api.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = aws_api_gateway_method.delete_product.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.product_manager.invoke_arn
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "product_api" {
  depends_on = [
    aws_api_gateway_integration.put_products_lambda,
    aws_api_gateway_integration.get_products_lambda,
    aws_api_gateway_integration.get_product_lambda,
    aws_api_gateway_integration.delete_product_lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.product_api.id
}

# API Gateway Stage
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.product_api.id
  rest_api_id   = aws_api_gateway_rest_api.product_api.id
  stage_name    = var.environment

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format = jsonencode({
      requestId          = "$context.requestId"
      ip                 = "$context.identity.sourceIp"
      requestTime        = "$context.requestTime"
      httpMethod         = "$context.httpMethod"
      resourcePath       = "$context.resourcePath"
      status             = "$context.status"
      protocol           = "$context.protocol"
      responseLength     = "$context.responseLength"
      integrationLatency = "$context.integration.latency"
    })
  }
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name = "API Gateway Logs"
  }
}

# Lambda permission to be invoked by API Gateway
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.product_manager.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:000000000000:${aws_api_gateway_rest_api.product_api.id}/*"
}

