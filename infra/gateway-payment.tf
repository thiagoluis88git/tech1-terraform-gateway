resource "aws_api_gateway_vpc_link" "main-payment" {
  name        = "fastfood_payment_gateway_vpclink"
  description = "Fastfood Gateway VPC Link."
  target_arns = [var.load_balancer_arn_payment]
}

resource "aws_api_gateway_rest_api" "main-payment" {
  name        = "fastfood_payment_gateway"
  description = "Fastfood Gateway used for EKS."
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# resource "aws_api_gateway_method" "root" {
#   rest_api_id   = aws_api_gateway_rest_api.main.id
#   resource_id   = aws_api_gateway_rest_api.main.root_resource_id
#   http_method   = "ANY"
#   authorization = "NONE"

#   request_parameters = {
#     "method.request.path.proxy"           = true
#     "method.request.header.Authorization" = true
#   }
# }

# resource "aws_api_gateway_integration" "root" {
#   rest_api_id = aws_api_gateway_rest_api.main.id
#   resource_id = aws_api_gateway_rest_api.main.root_resource_id
#   http_method = "ANY"

#   integration_http_method = "ANY"
#   type                    = "HTTP_PROXY"
#   uri                     = "http://a00a20833677c44dab49e0546060dea2-d221b0f381735b71.elb.us-east-1.amazonaws.com/"
#   passthrough_behavior    = "WHEN_NO_MATCH"
#   content_handling        = "CONVERT_TO_TEXT"

#   request_parameters = {
#     "integration.request.path.proxy"           = "method.request.path.proxy"
#     "integration.request.header.Accept"        = "'application/json'"
#     "integration.request.header.Authorization" = "method.request.header.Authorization"
#   }

#   connection_type = "VPC_LINK"
#   connection_id   = aws_api_gateway_vpc_link.main.id
# }

resource "aws_api_gateway_resource" "resource-payment-api" {
  rest_api_id = aws_api_gateway_rest_api.main-payment.id
  parent_id   = aws_api_gateway_rest_api.main-payment.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "method-payment-api" {
  rest_api_id   = aws_api_gateway_rest_api.main-payment.id
  resource_id   = aws_api_gateway_resource.resource-payment-api.id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.gateway-payment-authorizer.id

  request_parameters = {
    "method.request.path.proxy"           = true
    # "method.request.header.Authorization" = false
  }
}

resource "aws_api_gateway_integration" "payment-api" {
  rest_api_id = aws_api_gateway_rest_api.main-payment.id
  resource_id = aws_api_gateway_resource.resource-payment-api.id
  http_method = "ANY"

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.load_balancer_dns_payment}/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"

  request_parameters = {
    "integration.request.path.proxy"           = "method.request.path.proxy"
    "integration.request.header.Accept"        = "'application/json'"
    # "integration.request.header.Authorization" = "method.request.header.Authorization"
  }

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.main-payment.id
}

resource "aws_api_gateway_deployment" "deployment-payment" {
  rest_api_id = aws_api_gateway_rest_api.main-payment.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.main-payment.body))
    auto_deploy  = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_integration.payment-api]
}

resource "aws_api_gateway_stage" "stage_payment_prd" {
  deployment_id = aws_api_gateway_deployment.deployment-payment.id
  rest_api_id   = aws_api_gateway_rest_api.main-payment.id
  stage_name    = "prd"
}

resource "aws_api_gateway_authorizer" "gateway-payment-authorizer" {
  name                   = "gateway-payment-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.main-payment.id
  authorizer_uri         = aws_lambda_function.lambda-authorizer.invoke_arn
  authorizer_credentials = var.networking.fiap_role
  authorizer_result_ttl_in_seconds = 0
}

output "base_payment_url" {
  value = "${aws_api_gateway_stage.stage_payment_prd.invoke_url}/"
}
