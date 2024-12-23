variable "networking" {
  type = object({
    cidr_block      = string
    region          = string
    profile         = string
    vpc_name        = string
    fiap_role       = string
    azs             = list(string)
    public_subnets  = list(string)
    private_subnets = list(string)
    nat_gateways    = bool
  })
  default = {
    cidr_block      = "141.0.0.0/16"
    region          = "us-east-1"
    profile         = "fiap-local"
    vpc_name        = "fiap-vpc"
    fiap_role       = "arn:aws:iam::199710252834:role/LabRole"
    azs             = ["us-east-1a", "us-east-1b"]
    public_subnets  = ["141.0.1.0/24", "141.0.2.0/24"]
    private_subnets = ["141.0.3.0/24", "141.0.4.0/24"]
    nat_gateways    = true
  }
}

variable "load_balancer_arn_customer" {
  description = "Customer Load Balancer ARN"
  type        = string
  sensitive   = false
}

variable "load_balancer_dns_customer" {
  description = "Customer Load Balancer DNS"
  type        = string
  sensitive   = false
}

variable "load_balancer_arn_orders" {
  description = "Orders Load Balancer ARN"
  type        = string
  sensitive   = false
}

variable "load_balancer_dns_orders" {
  description = "Orders Load Balancer DNS"
  type        = string
  sensitive   = false
}

variable "load_balancer_arn_payment" {
  description = "Payment Load Balancer ARN"
  type        = string
  sensitive   = false
}

variable "load_balancer_dns_payment" {
  description = "Payment Load Balancer DNS"
  type        = string
  sensitive   = false
}

variable "fastfood_aws_access_key_id" {
  description = "Load Balancer DNS"
  type        = string
  sensitive   = true
}

variable "fastfood_aws_secret_access_key" {
  description = "Load Balancer DNS"
  type        = string
  sensitive   = true
}
