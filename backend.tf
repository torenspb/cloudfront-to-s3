terraform {
  required_version = ">= 1.3.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.41.0"
    }
  }
}

# mgmt account
provider "aws" {
  region = "eu-north-1"
  default_tags {
    tags = {
      Environment = "mgmt"
    }
  }
}

# s3 account
provider "aws" {
  region = "eu-north-1"
  alias  = "prod"
  assume_role {
    role_arn     = "arn:aws:iam::987654321000:role/OrganizationAccountAccessRole"
    session_name = "terraform"
  }
  default_tags {
    tags = {
      Environment = "prod"
    }
  }
}
