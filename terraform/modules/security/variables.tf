variable "name_prefix" {
  description = "Prefix used in resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups are created."
  type        = string
}

variable "node_port" {
  description = "Application port exposed from EC2 host to ALB."
  type        = number
}

variable "argocd_alb_port" {
  description = "Public ALB listener port for the ArgoCD UI."
  type        = number
}

variable "argocd_host_port" {
  description = "ArgoCD UI port exposed from EC2 host to ALB."
  type        = number
}

variable "grafana_alb_port" {
  description = "Public ALB listener port for Grafana."
  type        = number
}

variable "grafana_host_port" {
  description = "Grafana port exposed from EC2 host to ALB."
  type        = number
}

variable "prometheus_alb_port" {
  description = "Public ALB listener port for Prometheus."
  type        = number
}

variable "prometheus_host_port" {
  description = "Prometheus port exposed from EC2 host to ALB."
  type        = number
}

variable "common_tags" {
  description = "Common tags applied to all AWS resources."
  type        = map(string)
}
