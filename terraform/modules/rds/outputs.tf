output "endpoint" {
  description = "RDS PostgreSQL endpoint address."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS PostgreSQL port."
  value       = aws_db_instance.this.port
}

output "master_secret_arn" {
  description = "AWS-managed Secrets Manager ARN for the RDS master user."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
