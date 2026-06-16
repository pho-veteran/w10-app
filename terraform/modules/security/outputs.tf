output "alb_security_group_id" {
  description = "Security group ID for the public ALB."
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "Security group ID for the private EC2 minikube host."
  value       = aws_security_group.ec2.id
}
