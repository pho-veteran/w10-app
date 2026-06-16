locals {
  name_prefix = "${var.project_name}-${var.environment}"

  tag_schema = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
    Lab         = "aws-accelerator-p2-w10"
    Stack       = "bootstrap"
  }

  common_tags = local.tag_schema

  github_repository_slug   = "${var.github_repository_owner}/${var.github_repository_name}"
  github_actions_role_name = var.github_actions_role_name != "" ? var.github_actions_role_name : "${local.name_prefix}-github-actions-role"
  github_actions_allowed_subjects = [
    "repo:${local.github_repository_slug}:pull_request",
    "repo:${local.github_repository_slug}:ref:refs/heads/${var.github_oidc_main_branch}",
    "repo:${local.github_repository_slug}:environment:production",
  ]

  terraform_state_bucket_name = lower("${local.name_prefix}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-tfstate")
  terraform_state_key         = "${var.project_name}/${var.environment}/app/terraform.tfstate"
}
