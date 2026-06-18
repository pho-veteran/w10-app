output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the ALB and NAT Gateway."
  value       = aws_subnet.public[*].id
}

output "private_subnet_id" {
  description = "Private subnet ID used by the EC2 minikube host."
  value       = aws_subnet.private.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by RDS subnet groups."
  value       = [aws_subnet.private.id, aws_subnet.rds_private.id]
}
