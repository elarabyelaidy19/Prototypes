output "vpc_id" {
  value = aws_vpc.main.id
}

output "nat_gateway" {
  value = {
    id        = aws_nat_gateway.main.id
    public_ip = aws_eip.nat.public_ip
    subnet    = "public (lab03-public-subnet)"
  }
}

output "ec2_public" {
  value = {
    id         = aws_instance.public.id
    private_ip = aws_instance.public.private_ip
    public_ip  = aws_instance.public.public_ip
  }
}

output "ec2_private" {
  value = {
    id         = aws_instance.private.id
    private_ip = aws_instance.private.private_ip
  }
}

output "ssh_public" {
  value = "ssh -i ~/.ssh/id_ed25519 ec2-user@${aws_instance.public.public_ip}"
}

output "ssh_private_via_jump" {
  value = "ssh -i ~/.ssh/id_ed25519 -J ec2-user@${aws_instance.public.public_ip} ec2-user@${aws_instance.private.private_ip}"
}

output "route_tables" {
  value = "aws --profile lab ec2 describe-route-tables --filters Name=vpc-id,Values=${aws_vpc.main.id} --query RouteTables[].Routes --output table"
}
