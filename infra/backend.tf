terraform {
  backend "s3" {
    bucket = "ratl-fiaptech1-2024-terraform-state"
    key    = "fiap/tech-challenge-gateway"
    region = "us-east-1"
  }
}