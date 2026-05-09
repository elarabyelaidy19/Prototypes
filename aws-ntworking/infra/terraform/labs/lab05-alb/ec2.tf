# EC2 targets running nginx, one per private subnet.
# User data installs nginx and creates a page identifying which instance served.

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

resource "aws_security_group" "alb" {
  name        = "lab05-alb-sg"
  description = "Lab 05 ALB - HTTP from internet"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "lab05-alb-sg" }
}

resource "aws_security_group" "target" {
  name        = "lab05-target-sg"
  description = "Lab 05 targets - HTTP from ALB SG, SSH from operator"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "lab05-target-sg" }
}

# ALB SG: HTTP in from internet, all out
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "HTTP from internet"
}

resource "aws_vpc_security_group_egress_rule" "alb_out" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "All egress"
}

# Target SG: HTTP from ALB SG (SG-to-SG reference), SSH from operator
resource "aws_vpc_security_group_ingress_rule" "target_http_from_alb" {
  security_group_id            = aws_security_group.target.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  description                  = "HTTP from ALB SG only"
}

resource "aws_vpc_security_group_ingress_rule" "target_ssh" {
  security_group_id = aws_security_group.target.id
  cidr_ipv4         = local.my_ip
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  description       = "SSH from operator"
}

resource "aws_vpc_security_group_ingress_rule" "target_ssh_from_bastion" {
  security_group_id            = aws_security_group.target.id
  referenced_security_group_id = aws_security_group.target.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "SSH from bastion (same SG, self-ref)"
}

resource "aws_vpc_security_group_egress_rule" "target_out" {
  security_group_id = aws_security_group.target.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "All egress"
}

# ---------------------------------------------------------------------------
# Key pair
# ---------------------------------------------------------------------------

resource "aws_key_pair" "lab" {
  key_name   = "lab05-key"
  public_key = file("~/.ssh/id_ed25519.pub")

  tags = { Name = "lab05-key" }
}

# ---------------------------------------------------------------------------
# EC2 targets with nginx user data
# ---------------------------------------------------------------------------

resource "aws_instance" "target" {
  count                  = 2
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.target.id]
  key_name               = aws_key_pair.lab.key_name

  user_data = <<-EOF
    #!/bin/bash
    yum install -y nginx
    INSTANCE_ID=$(ec2-metadata -i | cut -d' ' -f2)
    AZ=$(ec2-metadata -z | cut -d' ' -f2)
    cat > /usr/share/nginx/html/index.html <<HTML
    <h1>Lab 05 - ALB Target</h1>
    <p>Instance: $INSTANCE_ID</p>
    <p>AZ: $AZ</p>
    <p>Private IP: $(hostname -I | tr -d ' ')</p>
    HTML
    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = { Name = "lab05-target-${count.index + 1}" }
}

# Bastion in public subnet for SSH access to private targets
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.target.id]
  key_name                    = aws_key_pair.lab.key_name
  associate_public_ip_address = true

  tags = { Name = "lab05-bastion" }
}
