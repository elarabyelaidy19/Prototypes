output "vpc_id" {
  value = aws_vpc.main.id
}

output "igw_id" {
  value = aws_internet_gateway.main.id
}

output "subnet_a" {
  value = {
    id   = aws_subnet.a.id
    cidr = aws_subnet.a.cidr_block
    az   = aws_subnet.a.availability_zone
    type = "public"
  }
}

output "subnet_b" {
  value = {
    id   = aws_subnet.b.id
    cidr = aws_subnet.b.cidr_block
    az   = aws_subnet.b.availability_zone
    type = "private"
  }
}

output "ec2_a" {
  value = {
    id         = aws_instance.a.id
    private_ip = aws_instance.a.private_ip
    public_ip  = aws_instance.a.public_ip
    az         = aws_instance.a.availability_zone
    type       = "public"
  }
}

output "ec2_b" {
  value = {
    id         = aws_instance.b.id
    private_ip = aws_instance.b.private_ip
    az         = aws_instance.b.availability_zone
    type       = "private"
  }
}

output "operator_ip" {
  value       = local.my_ip
  description = "Your public IP - SSH is locked to this"
}

output "ssh_into_a" {
  value       = "ssh -i ~/.ssh/id_ed25519 ec2-user@${aws_instance.a.public_ip}"
  description = "Direct SSH to public EC2-A (no EICE needed)"
}

output "ssh_into_b_via_a" {
  value       = "ssh -i ~/.ssh/id_ed25519 -J ec2-user@${aws_instance.a.public_ip} ec2-user@${aws_instance.b.private_ip}"
  description = "SSH to private EC2-B via EC2-A as jump host"
}

output "route_tables" {
  value       = "aws --profile lab ec2 describe-route-tables --filters \"Name=vpc-id,Values=${aws_vpc.main.id}\" --query 'RouteTables[].[Tags[?Key==`Name`].Value|[0],Routes]' --output table"
  description = "Show all route tables for this VPC"
}
