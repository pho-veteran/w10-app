variable "name_prefix" {
  description = "Prefix used in resource names."
  type        = string
}

variable "instance_name" {
  description = "Name tag and logical label for the EC2 instance."
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for the EC2 instance."
  type        = string
}

variable "ec2_security_group_id" {
  description = "Security group ID attached to the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "ami_id" {
  description = "AMI ID used for the EC2 instance."
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
}

variable "node_port" {
  description = "Application port exposed on the EC2 host."
  type        = number
}

variable "argocd_host_port" {
  description = "ArgoCD UI port exposed on the EC2 host."
  type        = number
}

variable "grafana_host_port" {
  description = "Grafana port exposed on the EC2 host."
  type        = number
}

variable "prometheus_host_port" {
  description = "Prometheus port exposed on the EC2 host."
  type        = number
}

variable "kubectl_version" {
  description = "Kubectl version installed on the EC2 instance."
  type        = string
}

variable "minikube_version" {
  description = "Minikube version installed on the EC2 instance."
  type        = string
}

variable "gitops_repo_url" {
  description = "GitOps repository URL cloned by EC2 user-data for ArgoCD bootstrap."
  type        = string
}

variable "private_key_path" {
  description = "Local path used by local provider to persist the generated SSH private key."
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all AWS resources."
  type        = map(string)
}
