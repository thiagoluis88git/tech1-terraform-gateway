data "terraform_remote_state" "fastfood-core" {
  backend = "s3"

  config = {
    bucket = "ratl-fiaptech1-2024-terraform-state"
    key    = "fiap/tech-challenge"
    region = "us-east-1"
  }
}

# data "aws_lb_listener" "fastfood-lb-listener" {
#   load_balancer_arn = var.internal_arn_nlb
#   port              = 443
# }

resource "aws_apigatewayv2_api" "fastfood-api" {
  name          = "fastfood-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "prd" {
  api_id = aws_apigatewayv2_api.fastfood-api.id

  name        = "prd"
  auto_deploy = true
}

resource "aws_security_group" "vpc-link-sg" {
  name   = "vpc-link-sg"
  vpc_id = data.terraform_remote_state.fastfood-core.outputs.vpc-id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_apigatewayv2_vpc_link" "vpc-link" {
  name               = "vpc-link"
  security_group_ids = [aws_security_group.vpc-link-sg.id]
  subnet_ids         = data.terraform_remote_state.fastfood-core.outputs.private-subnets-ids
}

resource "aws_apigatewayv2_integration" "fastfood-api-integration" {
  api_id = aws_apigatewayv2_api.fastfood-api.id

  integration_uri    = var.internal_arn_nlb
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpc-link.id
}

resource "aws_apigatewayv2_route" "fastfood-api-route" {
  api_id = aws_apigatewayv2_api.fastfood-api.id

  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.fastfood-api-integration.id}"
}

output "hello_base_url" {
  value = "${aws_apigatewayv2_stage.prd.invoke_url}/echo"
}