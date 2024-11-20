resource "aws_api_gateway_vpc_link" "main-orders" {
  name        = "fastfood_orders_gateway_vpclink"
  description = "Fastfood Gateway VPC Link."
  target_arns = [var.load_balancer_arn_orders]
}

resource "aws_api_gateway_rest_api" "main-orders" {
  name        = "fastfood_orders_gateway"
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

resource "aws_api_gateway_resource" "resource-orders-api" {
  rest_api_id = aws_api_gateway_rest_api.main-orders.id
  parent_id   = aws_api_gateway_rest_api.main-orders.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "method-orders-api" {
  rest_api_id   = aws_api_gateway_rest_api.main-orders.id
  resource_id   = aws_api_gateway_resource.resource-orders-api.id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.gateway-orders-authorizer.id

  request_parameters = {
    "method.request.path.proxy"           = true
    # "method.request.header.Authorization" = false
  }
}

resource "aws_api_gateway_integration" "orders-api" {
  rest_api_id = aws_api_gateway_rest_api.main-orders.id
  resource_id = aws_api_gateway_resource.resource-orders-api.id
  http_method = "ANY"

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.load_balancer_dns_orders}/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"

  request_parameters = {
    "integration.request.path.proxy"           = "method.request.path.proxy"
    "integration.request.header.Accept"        = "'application/json'"
    # "integration.request.header.Authorization" = "method.request.header.Authorization"
  }

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.main-orders.id
}

resource "aws_api_gateway_deployment" "deployment-orders" {
  rest_api_id = aws_api_gateway_rest_api.main-orders.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.main-orders.body))
    auto_deploy  = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_integration.orders-api]
}

resource "aws_api_gateway_stage" "stage_orders_prd" {
  deployment_id = aws_api_gateway_deployment.deployment-orders.id
  rest_api_id   = aws_api_gateway_rest_api.main-orders.id
  stage_name    = "prd"
}

resource "aws_api_gateway_authorizer" "gateway-orders-authorizer" {
  name                   = "gateway-orders-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.main-orders.id
  authorizer_uri         = aws_lambda_function.lambda-authorizer.invoke_arn
  authorizer_credentials = var.networking.fiap_role
  authorizer_result_ttl_in_seconds = 0
}

output "base_orders_url" {
  value = "${aws_api_gateway_stage.stage_orders_prd.invoke_url}/"
}
