terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    key          = "p2-w10-lab/lab/app/terraform.tfstate"
    use_lockfile = true
    region       = "ap-southeast-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
