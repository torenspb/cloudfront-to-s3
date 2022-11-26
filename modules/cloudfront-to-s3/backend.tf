terraform {
  required_version = ">= 1.3.5"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "4.41.0"
      configuration_aliases = [aws.s3, aws.cloudfront]
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "acm"
}
