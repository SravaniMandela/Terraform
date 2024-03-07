provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    local = {
      version = "~> 2.1"
    }
  }
}