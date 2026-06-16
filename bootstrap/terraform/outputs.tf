output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC. Copy this value into the AWS_GITHUB_ACTIONS_ROLE_ARN GitHub secret after bootstrap apply."
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "IAM role name for GitHub Actions OIDC."
  value       = aws_iam_role.github_actions.name
}

output "github_actions_oidc_provider_arn" {
  description = "IAM OIDC provider ARN for GitHub Actions."
  value       = aws_iam_openid_connect_provider.github_actions.arn
}

output "github_actions_repository" {
  description = "GitHub repository slug trusted by the OIDC role."
  value       = local.github_repository_slug
}

output "github_actions_allowed_subjects" {
  description = "GitHub OIDC token subject patterns allowed to assume the shared role."
  value       = local.github_actions_allowed_subjects
}

output "terraform_state_bucket_name" {
  description = "S3 bucket name for the app Terraform remote state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_key" {
  description = "S3 key used by the app Terraform remote state."
  value       = local.terraform_state_key
}

output "terraform_backend_init_command" {
  description = "Terraform init command for the app stack using the bootstrap remote state bucket."
  value       = "terraform -chdir=terraform init -backend-config=\"bucket=${aws_s3_bucket.terraform_state.bucket}\" -backend-config=\"region=${var.aws_region}\""
}
