variable "aws_region" {
  description = "AWS region used for all resources."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Short project name used in resource names and tags."
  type        = string
  default     = "p2-w10-lab"
}

variable "environment" {
  description = "Environment tag value."
  type        = string
  default     = "lab"
}

variable "owner" {
  description = "Owner tag value."
  type        = string
  default     = "vinhnt23it"
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets used by ALB and NAT Gateway."
  type        = list(string)
  default     = ["10.42.0.0/24", "10.42.1.0/24"]
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet used by the EC2 minikube host."
  type        = string
  default     = "10.42.10.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for the minikube host."
  type        = string
  default     = "t3.large"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB for the minikube host."
  type        = number
  default     = 20
}

variable "ami_id" {
  description = "Optional Ubuntu AMI ID. Leave empty to use the latest Ubuntu 22.04 LTS AMI."
  type        = string
  default     = ""
}

variable "node_port" {
  description = "Kubernetes NodePort and host port exposed to the ALB target group."
  type        = number
  default     = 30080

  validation {
    condition     = var.node_port >= 30000 && var.node_port <= 32767
    error_message = "node_port must be within the Kubernetes NodePort range 30000-32767."
  }
}

variable "argocd_alb_port" {
  description = "Public ALB listener port for the ArgoCD UI."
  type        = number
  default     = 8080

  validation {
    condition     = var.argocd_alb_port >= 1 && var.argocd_alb_port <= 65535
    error_message = "argocd_alb_port must be within 1-65535."
  }
}

variable "argocd_host_port" {
  description = "Host port on the EC2 instance forwarded to the ArgoCD server service."
  type        = number
  default     = 30081

  validation {
    condition     = var.argocd_host_port >= 1 && var.argocd_host_port <= 65535
    error_message = "argocd_host_port must be within 1-65535."
  }
}

variable "grafana_alb_port" {
  description = "Public ALB listener port for Grafana."
  type        = number
  default     = 8081

  validation {
    condition     = var.grafana_alb_port >= 1 && var.grafana_alb_port <= 65535
    error_message = "grafana_alb_port must be within 1-65535."
  }
}

variable "grafana_host_port" {
  description = "Host port on the EC2 instance forwarded to Grafana."
  type        = number
  default     = 30082

  validation {
    condition     = var.grafana_host_port >= 1 && var.grafana_host_port <= 65535
    error_message = "grafana_host_port must be within 1-65535."
  }
}

variable "prometheus_alb_port" {
  description = "Public ALB listener port for Prometheus."
  type        = number
  default     = 8082

  validation {
    condition     = var.prometheus_alb_port >= 1 && var.prometheus_alb_port <= 65535
    error_message = "prometheus_alb_port must be within 1-65535."
  }
}

variable "prometheus_host_port" {
  description = "Host port on the EC2 instance forwarded to Prometheus."
  type        = number
  default     = 30083

  validation {
    condition     = var.prometheus_host_port >= 1 && var.prometheus_host_port <= 65535
    error_message = "prometheus_host_port must be within 1-65535."
  }
}


variable "minikube_version" {
  description = "Minikube version to install on the EC2 instance."
  type        = string
  default     = "v1.33.1"
}

variable "kubectl_version" {
  description = "Kubectl version to install on the EC2 instance."
  type        = string
  default     = "v1.30.3"
}


variable "gitops_repo_url" {
  description = "GitOps repository URL cloned by EC2 user-data for ArgoCD bootstrap."
  type        = string
  default     = "https://github.com/pho-veteran/w10-gitops.git"
}
