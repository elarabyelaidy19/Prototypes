# Lab 02 - Public Subnet (IGW + Route Tables)
#
# Goal: prove that a subnet becomes "public" ONLY when three things align:
#   1. An Internet Gateway attached to the VPC
#   2. A route table with 0.0.0.0/0 -> IGW
#   3. The instance has a public IP (for the IGW to NAT)
#
# Subnet A gets all three -> public.
# Subnet B gets none -> still the isolated island from Lab 1.

data "aws_availability_zones" "available" {
  state = "available"
}

# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "lab02-vpc" }
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------

resource "aws_subnet" "a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = { Name = "lab02-subnet-a-public" }
}

resource "aws_subnet" "b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_b_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = { Name = "lab02-subnet-b-private" }
}

# ---------------------------------------------------------------------------
# Internet Gateway - the new piece
# ---------------------------------------------------------------------------
# An IGW is a VPC-level component. It does two things:
#   1. Acts as a target in route tables (0.0.0.0/0 -> igw-xxx)
#   2. Performs 1:1 NAT between public and private IPs
# By itself it does nothing - a route must point to it.

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "lab02-igw" }
}

# ---------------------------------------------------------------------------
# Route tables
# ---------------------------------------------------------------------------
# Every VPC has an auto-created "main" route table with one rule:
#   10.0.0.0/16 -> local
#
# We create a CUSTOM route table for subnet A that adds:
#   0.0.0.0/0 -> IGW
#
# Subnet B stays on the default main RT (no IGW route = private).

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "lab02-public-rt" }
}

resource "aws_route_table_association" "subnet_a_public" {
  subnet_id      = aws_subnet.a.id
  route_table_id = aws_route_table.public.id
}
