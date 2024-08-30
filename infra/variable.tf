variable "internal_arn_elb" {
  description = "ARN Internal ELB provided by the Kubernetes Service on EKS"
  type        = string
  sensitive   = false
}