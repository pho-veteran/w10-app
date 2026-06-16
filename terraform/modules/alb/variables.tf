variable "name_prefix" {
  description = "Prefix used in resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the ALB and target group."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs attached to the ALB."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID attached to the ALB."
  type        = string
}

variable "target_instance_id" {
  description = "EC2 instance ID registered in the target group."
  type        = string
}

variable "target_port" {
  description = "Host port on the EC2 instance used by the target group."
  type        = number
}

variable "argocd_alb_port" {
  description = "Public ALB listener port for the ArgoCD UI."
  type        = number
}

variable "argocd_target_port" {
  description = "Host port on the EC2 instance used by the ArgoCD target group."
  type        = number
}

variable "grafana_alb_port" {
  description = "Public ALB listener port for Grafana."
  type        = number
}

variable "grafana_target_port" {
  description = "Host port on the EC2 instance used by the Grafana target group."
  type        = number
}

variable "prometheus_alb_port" {
  description = "Public ALB listener port for Prometheus."
  type        = number
}

variable "prometheus_target_port" {
  description = "Host port on the EC2 instance used by the Prometheus target group."
  type        = number
}

variable "common_tags" {
  description = "Common tags applied to all AWS resources."
  type        = map(string)
}
