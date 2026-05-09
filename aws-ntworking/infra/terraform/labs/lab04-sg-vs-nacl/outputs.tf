output "vpc_id" {
  value = aws_vpc.main.id
}

output "ec2" {
  value = {
    id         = aws_instance.main.id
    private_ip = aws_instance.main.private_ip
    public_ip  = aws_instance.main.public_ip
  }
}

output "sg_id" {
  value       = aws_security_group.instance.id
  description = "SG ID - use this for CLI experiments"
}

output "nacl_id" {
  value       = aws_network_acl.lab.id
  description = "NACL ID - use this for CLI experiments"
}

output "operator_ip" {
  value = local.my_ip
}

output "ssh" {
  value = "ssh -i ~/.ssh/id_ed25519 ec2-user@${aws_instance.main.public_ip}"
}

output "egress_rule_id" {
  value       = aws_vpc_security_group_egress_rule.all_out.id
  description = "Egress rule ID - needed to revoke it in experiments"
}
