terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}
