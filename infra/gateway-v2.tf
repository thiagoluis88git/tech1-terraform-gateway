resource "aws_apigatewayv2_api" "fastfood-api" {
  name          = "fastfood-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "prd" {
  api_id = aws_apigatewayv2_api.fastfood-api.id

  name        = "prd"
  auto_deploy = true
}

resource "aws_security_group" "sg-vpc-link" {
  name   = "sg-vpc-link"
  vpc_id = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_apigatewayv2_vpc_link" "vpc-link" {
  name               = "vpc-link"
  security_group_ids = [aws_security_group.sg-vpc-link.id]
  subnet_ids         = flatten([aws_subnet.private-subnet[*].id])
}

resource "aws_apigatewayv2_integration" "fastfood-api-integration" {
  api_id = aws_apigatewayv2_api.fastfood-api.id

  integration_uri    = var.internal_arn_nlb
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpc-link.id
}

resource "aws_apigatewayv2_route" "get_echo" {
  api_id = aws_apigatewayv2_api.fastfood-api.id

  route_key = "GET /echo"
  target    = "integrations/${aws_apigatewayv2_integration.fastfood-api-integration.id}"
}

output "hello_base_url" {
  value = "${aws_apigatewayv2_stage.prd.invoke_url}/echo"
}