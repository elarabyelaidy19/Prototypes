variable "region" {
  description = "AWS region for the lab"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet (hosts NAT GW + EC2-A)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet (hosts EC2-B, routes through NAT)"
  type        = string
  default     = "10.0.2.0/24"
}
