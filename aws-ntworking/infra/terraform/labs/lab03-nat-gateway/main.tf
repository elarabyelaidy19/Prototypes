# Lab 03 - Private Subnet + NAT Gateway
#
# Goal: prove that a NAT Gateway gives private-subnet instances outbound
# internet (yum install, curl) while blocking all inbound from the internet.
#
# Architecture:
#   Public subnet  → IGW route, hosts EC2-A + NAT Gateway
#   Private subnet → NAT route (0.0.0.0/0 → nat-xxx), hosts EC2-B
#
# The NAT Gateway lives in the PUBLIC subnet because it needs IGW access
# itself. Private subnet's route table points 0.0.0.0/0 at the NAT GW.

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

  tags = { Name = "lab03-vpc" }
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = { Name = "lab03-public-subnet" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = { Name = "lab03-private-subnet" }
}

# ---------------------------------------------------------------------------
# Internet Gateway (same as Lab 2)
# ---------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "lab03-igw" }
}

# ---------------------------------------------------------------------------
# NAT Gateway — the new piece
# ---------------------------------------------------------------------------
# Needs: an Elastic IP (public address for outbound NAT) and placement
# in the public subnet (so it can reach IGW itself).

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = { Name = "lab03-nat-eip" }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.main]

  tags = { Name = "lab03-nat-gw" }
}

# ---------------------------------------------------------------------------
# Route tables
# ---------------------------------------------------------------------------

# Public route table: 0.0.0.0/0 → IGW (same as Lab 2)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "lab03-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private route table: 0.0.0.0/0 → NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = { Name = "lab03-private-rt" }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
