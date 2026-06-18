output "endpoint" {
  description = "RDS PostgreSQL endpoint address."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS PostgreSQL port."
  value       = aws_db_instance.this.port
}

output "master_secret_arn" {
  description = "Static Secrets Manager ARN for the Day-B RDS connection secret."
  value       = aws_secretsmanager_secret.rds.arn
}
