output "alb_dns" {
  value       = aws_lb.main.dns_name
  description = "Hit this URL in your browser"
}

output "alb_url" {
  value = "http://${aws_lb.main.dns_name}"
}

output "target_group_arn" {
  value = aws_lb_target_group.nginx.arn
}

output "targets" {
  value = [for i, inst in aws_instance.target : {
    id         = inst.id
    private_ip = inst.private_ip
    az         = inst.availability_zone
    subnet     = aws_subnet.private[i].id
  }]
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "ssh_to_target_1" {
  value = "ssh -i ~/.ssh/id_ed25519 -J ec2-user@${aws_instance.bastion.public_ip} ec2-user@${aws_instance.target[0].private_ip}"
}

output "ssh_to_target_2" {
  value = "ssh -i ~/.ssh/id_ed25519 -J ec2-user@${aws_instance.bastion.public_ip} ec2-user@${aws_instance.target[1].private_ip}"
}

output "check_target_health" {
  value = "aws --profile lab elbv2 describe-target-health --target-group-arn ${aws_lb_target_group.nginx.arn} --query 'TargetHealthDescriptions[].{Target:Target.Id,Health:TargetHealth.State}' --output table"
}
