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
  region = var.aws_region
}

# Logs bucket (no lifecycle, no versioning)
module "s3_bucket_logs" {
  source = "../../modules/s3-bucket"

  bucket_name = "${var.bucket_prefix}-logs-${data.aws_caller_identity.current.account_id}"
  environment = var.environment

  enable_versioning = false
  enable_encryption = true
  enable_logging    = false
  force_destroy     = var.force_destroy

  tags = merge(
    var.common_tags,
    {
      Purpose = "Access Logs"
    }
  )
}

# Main application bucket (with all features enabled)
module "s3_bucket_application" {
  source = "../../modules/s3-bucket"

  bucket_name = "${var.bucket_prefix}-app-${data.aws_caller_identity.current.account_id}"
  environment = var.environment

  enable_versioning = true
  enable_encryption = true
  enable_logging    = true

  logging_target_bucket = module.s3_bucket_logs.bucket_id
  logging_target_prefix = "application-logs/"

  enable_lifecycle_rules = true
  lifecycle_config = {
    transition_to_ia_days           = 30
    transition_to_glacier_days      = 90
    expiration_days                 = 365
    abort_incomplete_multipart_days = 7
  }

  cors_rules = var.cors_enabled ? [
    {
      allowed_methods = ["GET", "PUT", "POST", "DELETE"]
      allowed_origins = var.allowed_origins
      allowed_headers = ["*"]
      expose_headers  = ["Content-Length", "ETag"]
      max_age_seconds = 3600
    }
  ] : []

  enable_public_access_block = true
  block_public_acls          = true
  block_public_policy        = true
  ignore_public_acls         = true
  restrict_public_buckets    = true

  force_destroy = var.force_destroy

  tags = merge(
    var.common_tags,
    {
      Purpose = "Application Data"
      Tier    = "Gold"
    }
  )
}

data "aws_caller_identity" "current" {}

# Outputs
output "logs_bucket_id" {
  value       = module.s3_bucket_logs.bucket_id
  description = "Logs bucket ID"
}

output "logs_bucket_arn" {
  value       = module.s3_bucket_logs.bucket_arn
  description = "Logs bucket ARN"
}

output "application_bucket_id" {
  value       = module.s3_bucket_application.bucket_id
  description = "Application bucket ID"
}

output "application_bucket_arn" {
  value       = module.s3_bucket_application.bucket_arn
  description = "Application bucket ARN"
}

output "application_bucket_domain_name" {
  value       = module.s3_bucket_application.bucket_domain_name
  description = "Regional domain name of the application bucket"
}
