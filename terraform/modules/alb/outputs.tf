output "alb_dns_name" {
  description = "ALB DNS name."
  value       = aws_lb.app.dns_name
}

output "app_url" {
  description = "Public URL served by the ALB."
  value       = "http://${aws_lb.app.dns_name}"
}

output "argocd_url" {
  description = "Public ArgoCD UI URL served by the ALB."
  value       = "http://${aws_lb.app.dns_name}:${var.argocd_alb_port}"
}

output "grafana_url" {
  description = "Public Grafana URL served by the ALB."
  value       = "http://${aws_lb.app.dns_name}:${var.grafana_alb_port}"
}

output "prometheus_url" {
  description = "Public Prometheus URL served by the ALB."
  value       = "http://${aws_lb.app.dns_name}:${var.prometheus_alb_port}"
}
