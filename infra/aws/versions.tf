terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote, encrypted, locked state. Create the bucket once, then uncomment.
  # backend "s3" {
  #   bucket       = "your-terraform-state-bucket"
  #   key          = "secure-gitops-platform/terraform.tfstate"
  #   region       = "us-east-1"
  #   encrypt      = true
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "secure-gitops-platform"
      ManagedBy = "terraform"
    }
  }
}
