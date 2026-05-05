# Lab 00 — Smoke test
#
# Goal: prove the whole tooling chain (Terraform → tflocal → LocalStack) works
# by creating one trivial resource (a VPC) and reading it back.
#
# What's NOT here on purpose:
#   - No subnets, no IGW, no routes — that's Lab 01.
#   - No LocalStack-specific endpoint config in the provider block; tflocal
#     injects fake creds and endpoint overrides for us.

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "smoke" {
  cidr_block = "10.99.0.0/16"

  tags = {
    Name = "lab00-smoke"
    Lab  = "00"
  }
}

output "vpc_id" {
  value       = aws_vpc.smoke.id
  description = "ID of the smoke-test VPC; should appear in LocalStack's describe-vpcs"
}

output "vpc_cidr" {
  value = aws_vpc.smoke.cidr_block
}
