# EC2 instances + EC2 Instance Connect Endpoint (EICE).
#
# EICE is the magic that lets us SSH into private-subnet instances without an
# IGW, NAT, or public IPs. AWS provides a managed tunnel: your laptop -> AWS
# control plane -> EICE -> instance's private IP. Free for the endpoint
# itself; small data charges per session.
#
# This means the instances themselves still have ZERO internet egress —
# perfect for proving the lab's central claim that an "island" subnet has no
# path out. EICE is purely a control-plane back door for the lab operator.

# Latest Amazon Linux 2023 AMI. Looked up at apply time so we never pin a
# stale AMI ID that AWS will eventually deprecate.
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

# ---------------------------------------------------------------------------
# Security groups — the bouncers
# ---------------------------------------------------------------------------

# SG for the two lab EC2 instances.
resource "aws_security_group" "instance" {
  name        = "lab01-instance-sg"
  description = "Lab 01 EC2s: SSH from EICE only, ICMP from VPC"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "lab01-instance-sg" }
}

# SG referenced by EICE itself.
resource "aws_security_group" "eice" {
  name        = "lab01-eice-sg"
  description = "Lab 01 EICE endpoint - egress SSH to instance SG"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "lab01-eice-sg" }
}

# Allow SSH (tcp/22) into instances ONLY from the EICE endpoint's SG.
# Note: SG-to-SG references are AWS's idiomatic way to say "whoever's wearing
# this SG, let them in" — far better than CIDR rules because the source IP can
# change but the SG identity is stable.
resource "aws_vpc_security_group_ingress_rule" "ssh_from_eice" {
  security_group_id            = aws_security_group.instance.id
  referenced_security_group_id = aws_security_group.eice.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "SSH from EICE endpoint only"
}

# Allow ICMP (ping) from anywhere within the VPC, so EC2-A can ping EC2-B and
# vice versa for our behavioral test.
resource "aws_vpc_security_group_ingress_rule" "icmp_from_vpc" {
  security_group_id = aws_security_group.instance.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  ip_protocol       = "icmp"
  from_port         = -1 # -1/-1 = "all ICMP types/codes"
  to_port           = -1
  description       = "Allow ICMP from any IP in the VPC"
}

# Allow ALL outbound. Important pedagogically: even with the most permissive
# egress rule possible, the instances STILL can't reach the internet because
# there's no IGW/NAT. SGs are necessary but not sufficient for connectivity.
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all protocols
  description       = "Egress to anywhere (will still fail without IGW/NAT)"
}

# EICE needs to initiate SSH outbound to the instance SG.
resource "aws_vpc_security_group_egress_rule" "eice_to_instances" {
  security_group_id            = aws_security_group.eice.id
  referenced_security_group_id = aws_security_group.instance.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Egress SSH from EICE to instance SG"
}

# ---------------------------------------------------------------------------
# Instances
# ---------------------------------------------------------------------------

resource "aws_instance" "a" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro" # free tier
  subnet_id              = aws_subnet.a.id
  vpc_security_group_ids = [aws_security_group.instance.id]

  # No key_name and no public IP. EICE handles SSH; without it, the instance
  # would be unreachable from anywhere.

  tags = { Name = "lab01-ec2-a" }
}

resource "aws_instance" "b" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.b.id
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = { Name = "lab01-ec2-b" }
}

# ---------------------------------------------------------------------------
# EC2 Instance Connect Endpoint
# ---------------------------------------------------------------------------
#
# Lives in subnet A but reaches instances anywhere in the same VPC via the
# implicit local route. One endpoint per VPC is plenty for a lab.

resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id          = aws_subnet.a.id
  security_group_ids = [aws_security_group.eice.id]

  tags = { Name = "lab01-eice" }
}
