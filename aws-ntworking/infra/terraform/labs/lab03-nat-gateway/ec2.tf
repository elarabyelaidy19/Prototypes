# EC2 instances + Security Groups for Lab 03.

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  my_ip = "${trimspace(data.http.my_ip.response_body)}/32"
}

# ---------------------------------------------------------------------------
# Security groups
# ---------------------------------------------------------------------------

resource "aws_security_group" "public" {
  name        = "lab03-public-sg"
  description = "Lab 03 public EC2 - SSH from operator, ICMP from VPC"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "lab03-public-sg" }
}

resource "aws_security_group" "private" {
  name        = "lab03-private-sg"
  description = "Lab 03 private EC2 - SSH from public SG, ICMP from VPC"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "lab03-private-sg" }
}

# --- Public SG rules ---

resource "aws_vpc_security_group_ingress_rule" "ssh_from_operator" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4         = local.my_ip
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  description       = "SSH from operator IP"
}

resource "aws_vpc_security_group_ingress_rule" "icmp_public" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  description       = "ICMP from VPC"
}

resource "aws_vpc_security_group_egress_rule" "public_all_out" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "All egress"
}

# --- Private SG rules ---

resource "aws_vpc_security_group_ingress_rule" "ssh_from_public_sg" {
  security_group_id            = aws_security_group.private.id
  referenced_security_group_id = aws_security_group.public.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "SSH from public SG (jump box)"
}

resource "aws_vpc_security_group_ingress_rule" "icmp_private" {
  security_group_id = aws_security_group.private.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  description       = "ICMP from VPC"
}

resource "aws_vpc_security_group_egress_rule" "private_all_out" {
  security_group_id = aws_security_group.private.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "All egress"
}

# ---------------------------------------------------------------------------
# Key pair
# ---------------------------------------------------------------------------

resource "aws_key_pair" "lab" {
  key_name   = "lab03-key"
  public_key = file("~/.ssh/id_ed25519.pub")

  tags = { Name = "lab03-key" }
}

# ---------------------------------------------------------------------------
# Instances
# ---------------------------------------------------------------------------

resource "aws_instance" "public" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.public.id]
  key_name                    = aws_key_pair.lab.key_name
  associate_public_ip_address = true

  tags = { Name = "lab03-ec2-public" }
}

resource "aws_instance" "private" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name               = aws_key_pair.lab.key_name

  tags = { Name = "lab03-ec2-private" }
}
