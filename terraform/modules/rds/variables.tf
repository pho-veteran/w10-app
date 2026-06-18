variable "name_prefix" {
  description = "Prefix used in resource names."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID attached to the RDS instance."
  type        = string
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "database_name" {
  description = "Initial PostgreSQL database name."
  type        = string
}

variable "username" {
  description = "PostgreSQL username."
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all AWS resources."
  type        = map(string)
}
