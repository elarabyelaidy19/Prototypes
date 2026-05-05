output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the lab VPC"
}

output "subnet_a" {
  value = {
    id         = aws_subnet.a.id
    cidr       = aws_subnet.a.cidr_block
    az         = aws_subnet.a.availability_zone
  }
}

output "subnet_b" {
  value = {
    id         = aws_subnet.b.id
    cidr       = aws_subnet.b.cidr_block
    az         = aws_subnet.b.availability_zone
  }
}

output "ec2_a" {
  value = {
    id         = aws_instance.a.id
    private_ip = aws_instance.a.private_ip
    az         = aws_instance.a.availability_zone
  }
}

output "ec2_b" {
  value = {
    id         = aws_instance.b.id
    private_ip = aws_instance.b.private_ip
    az         = aws_instance.b.availability_zone
  }
}

output "eice_id" {
  value = aws_ec2_instance_connect_endpoint.main.id
}

# Ready-to-paste SSH commands. Use these to verify behavior in the lab.
output "ssh_into_a" {
  value       = "aws --profile lab ec2-instance-connect ssh --instance-id ${aws_instance.a.id} --connection-type eice"
  description = "SSH into EC2-A via EICE (no IGW/NAT/public-IP needed)"
}

output "ssh_into_b" {
  value       = "aws --profile lab ec2-instance-connect ssh --instance-id ${aws_instance.b.id} --connection-type eice"
  description = "SSH into EC2-B via EICE"
}
