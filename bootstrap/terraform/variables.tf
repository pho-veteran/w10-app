variable "aws_region" {
  description = "AWS region used for bootstrap IAM and OIDC resources."
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

variable "github_repository_owner" {
  description = "GitHub owner or organization allowed to assume the lab OIDC role."
  type        = string
  default     = "pho-veteran"
}

variable "github_repository_name" {
  description = "GitHub repository name allowed to assume the lab OIDC role."
  type        = string
  default     = "w10-app"
}

variable "github_oidc_main_branch" {
  description = "Main branch name allowed to assume the lab OIDC role for apply workflow."
  type        = string
  default     = "main"
}

variable "github_actions_role_name" {
  description = "Optional custom IAM role name for GitHub Actions OIDC. Leave empty to use the lab naming convention."
  type        = string
  default     = ""
}

variable "github_oidc_thumbprints" {
  description = "Thumbprints trusted by the GitHub Actions OIDC provider."
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
