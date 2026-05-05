# Lab 01 — VPC + Subnets (Islands)
#
# Goal: prove that a VPC and its subnets are isolated from the internet by
# default, but instances within the same VPC can talk to each other via the
# implicit local route.
#
# What's intentionally absent:
#   - Internet Gateway        (Lab 2)
#   - NAT Gateway             (Lab 3)
#   - Custom route tables     (Lab 2)
# All routing falls through to the auto-created "main" route table that ships
# with every VPC, which contains exactly one rule: vpc_cidr -> local.

# Pick the first 2 AZs in this region. us-east-1 has 6; we just need 2 to
# demonstrate cross-AZ subnet placement.
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  # enable_dns_support: lets the in-VPC resolver (10.0.0.2) answer DNS queries.
  # enable_dns_hostnames: gives instances internal hostnames (ip-10-0-1-4.ec2.internal).
  # Both default true on Console-created VPCs but Terraform defaults them to
  # false — explicitly setting both prevents future "why won't DNS work?" bugs.
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "lab01-vpc" }
}

resource "aws_subnet" "a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = { Name = "lab01-subnet-a" }
}

resource "aws_subnet" "b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_b_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = { Name = "lab01-subnet-b" }
}
