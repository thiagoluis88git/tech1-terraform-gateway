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
    fiap_role       = "arn:aws:iam::714167738697:role/LabRole"
    azs             = ["us-east-1a", "us-east-1b"]
    public_subnets  = ["141.0.1.0/24", "141.0.2.0/24"]
    private_subnets = ["141.0.3.0/24", "141.0.4.0/24"]
    nat_gateways    = true
  }
}

variable "internal_arn_nlb" {
  description = "ARN Internal NLB provided by the Kubernetes Service on EKS"
  type        = string
  sensitive   = false
}
