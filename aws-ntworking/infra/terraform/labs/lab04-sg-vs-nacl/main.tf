# Lab 04 — Security Groups vs NACLs
#
# Goal: prove the behavioral difference between stateful (SG) and
# stateless (NACL) firewalls by breaking SSH with each and observing
# which layer killed the connection.
#
# Setup: one public subnet, one EC2, one custom NACL.
# We'll modify SG/NACL rules LIVE via CLI to observe effects.

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "lab04-vpc" }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = { Name = "lab04-subnet" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "lab04-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "lab04-public-rt" }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# Custom NACL — starts permissive, we'll tighten via CLI
# ---------------------------------------------------------------------------

resource "aws_network_acl" "lab" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.main.id]

  tags = { Name = "lab04-nacl" }
}

resource "aws_network_acl_rule" "inbound_all" {
  network_acl_id = aws_network_acl.lab.id
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
  egress         = false
}

resource "aws_network_acl_rule" "outbound_all" {
  network_acl_id = aws_network_acl.lab.id
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
  egress         = true
}
