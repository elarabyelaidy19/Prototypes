# EC2 instances + Security Groups for Lab 02.
#
# Key difference from Lab 1: EC2-A gets a public IP and lives in the
# public subnet. EC2-B remains private (no public IP, no IGW route).
# We also allow SSH from the operator's IP directly (no EICE needed
# for the public instance).

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

# Look up our current public IP so we can lock SSH to it.
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  my_ip = "${trimspace(data.http.my_ip.response_body)}/32"
}

# ---------------------------------------------------------------------------
# Security groups
# ---------------------------------------------------------------------------

resource "aws_security_group" "public_instance" {
  name        = "lab02-public-sg"
  description = "Lab 02 public EC2: SSH from operator IP, ICMP from VPC"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "lab02-public-sg" }
}

resource "aws_security_group" "private_instance" {
  name        = "lab02-private-sg"
  description = "Lab 02 private EC2: SSH from public SG, ICMP from VPC"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "lab02-private-sg" }
}

# --- Public SG rules ---

resource "aws_vpc_security_group_ingress_rule" "ssh_from_operator" {
  security_group_id = aws_security_group.public_instance.id
  cidr_ipv4         = local.my_ip
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  description       = "SSH from operator IP only"
}

resource "aws_vpc_security_group_ingress_rule" "icmp_public" {
  security_group_id = aws_security_group.public_instance.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  description       = "ICMP from VPC"
}

resource "aws_vpc_security_group_egress_rule" "public_all_out" {
  security_group_id = aws_security_group.public_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "All egress"
}

# --- Private SG rules ---

resource "aws_vpc_security_group_ingress_rule" "ssh_from_public_sg" {
  security_group_id            = aws_security_group.private_instance.id
  referenced_security_group_id = aws_security_group.public_instance.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description       = "SSH from public instance SG (jump box pattern)"
}

resource "aws_vpc_security_group_ingress_rule" "icmp_private" {
  security_group_id = aws_security_group.private_instance.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  description       = "ICMP from VPC"
}

resource "aws_vpc_security_group_egress_rule" "private_all_out" {
  security_group_id = aws_security_group.private_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "All egress"
}

# ---------------------------------------------------------------------------
# Key pair - needed for direct SSH (no EICE this time for public instance)
# ---------------------------------------------------------------------------

resource "aws_key_pair" "lab" {
  key_name   = "lab02-key"
  public_key = file("~/.ssh/id_ed25519.pub")

  tags = { Name = "lab02-key" }
}

# ---------------------------------------------------------------------------
# Instances
# ---------------------------------------------------------------------------

resource "aws_instance" "a" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.a.id
  vpc_security_group_ids      = [aws_security_group.public_instance.id]
  key_name                    = aws_key_pair.lab.key_name
  associate_public_ip_address = true

  tags = { Name = "lab02-ec2-a-public" }
}

resource "aws_instance" "b" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.b.id
  vpc_security_group_ids = [aws_security_group.private_instance.id]
  key_name               = aws_key_pair.lab.key_name

  tags = { Name = "lab02-ec2-b-private" }
}
