output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.this.id
}

output "private_key_path" {
  description = "Local path of the generated optional break-glass SSH private key."
  value       = local_sensitive_file.ssh_private_key.filename
  sensitive   = true
}
