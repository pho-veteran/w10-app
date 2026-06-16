variable "name_prefix" {
  description = "Prefix used in resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all AWS resources."
  type        = map(string)
}
