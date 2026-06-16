locals {
  name_prefix = "${var.project_name}-${var.environment}"

  tag_schema = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
    Lab         = "aws-accelerator-p2-w10"
  }

  common_tags = local.tag_schema

  private_key_path = "${path.module}/.generated/${local.name_prefix}.pem"

}
