terraform {
  required_version = "~> 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "s3_bucket_minimal" {
  source = "../../modules/s3-bucket"

  bucket_name = "example-minimal-${data.aws_caller_identity.current.account_id}"
  environment = "dev"
}

data "aws_caller_identity" "current" {}

output "bucket_id" {
  value       = module.s3_bucket_minimal.bucket_id
  description = "The S3 bucket ID"
}

output "bucket_arn" {
  value       = module.s3_bucket_minimal.bucket_arn
  description = "The S3 bucket ARN"
}
