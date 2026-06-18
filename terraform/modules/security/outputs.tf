output "alb_security_group_id" {
  description = "Security group ID for the public ALB."
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "Security group ID for the private EC2 minikube host."
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "Security group ID for private RDS PostgreSQL."
  value       = aws_security_group.rds.id
}

output "secretsmanager_endpoint_security_group_id" {
  description = "Security group ID for the Secrets Manager interface endpoint."
  value       = aws_security_group.secretsmanager_endpoint.id
}
