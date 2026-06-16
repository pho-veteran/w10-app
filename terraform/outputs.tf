output "app_url" {
  description = "Public URL served by the ALB."
  value       = module.alb.app_url
}

output "argocd_url" {
  description = "Public ArgoCD UI URL served by the ALB."
  value       = module.alb.argocd_url
}

output "grafana_url" {
  description = "Public Grafana URL served by the ALB."
  value       = module.alb.grafana_url
}

output "prometheus_url" {
  description = "Public Prometheus URL served by the ALB."
  value       = module.alb.prometheus_url
}

output "alb_dns_name" {
  description = "ALB DNS name."
  value       = module.alb.alb_dns_name
}

output "instance_id" {
  description = "Private EC2 instance ID for SSM access."
  value       = module.ec2.instance_id
}

output "ssm_connect_command" {
  description = "Command for connecting to the private EC2 instance with SSM Session Manager."
  value       = "aws ssm start-session --target ${module.ec2.instance_id} --region ${var.aws_region}"
}

output "private_key_path" {
  description = "Local path of the generated optional break-glass SSH private key. SSH inbound is not opened by default."
  value       = module.ec2.private_key_path
  sensitive   = true
}
