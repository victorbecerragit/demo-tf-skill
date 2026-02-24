run "basic_bucket_creation" {
  command = plan

  variables {
    bucket_name = "test-bucket-basic"
    environment = "dev"
  }

  assert {
    condition     = aws_s3_bucket.this[0].bucket == "test-bucket-basic"
    error_message = "Bucket name does not match"
  }

  assert {
    condition     = contains(keys(aws_s3_bucket.this[0].tags), "Environment")
    error_message = "Environment tag is missing"
  }

  assert {
    condition     = aws_s3_bucket.this[0].tags["Environment"] == "dev"
    error_message = "Environment tag value is incorrect"
  }
}

run "encryption_enabled_by_default" {
  command = plan

  variables {
    bucket_name       = "test-bucket-encryption"
    environment       = "dev"
    enable_encryption = true
  }

  assert {
    condition     = length(aws_s3_bucket_server_side_encryption_configuration.this) > 0
    error_message = "Encryption configuration not created"
  }

  assert {
    condition     = length(aws_s3_bucket_server_side_encryption_configuration.this[0].rule) > 0
    error_message = "Encryption rules not configured"
  }
}

run "public_access_block_enabled" {
  command = plan

  variables {
    bucket_name                = "test-bucket-pab"
    environment                = "dev"
    enable_public_access_block = true
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this[0].block_public_acls == true
    error_message = "block_public_acls is not true"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this[0].block_public_policy == true
    error_message = "block_public_policy is not true"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this[0].ignore_public_acls == true
    error_message = "ignore_public_acls is not true"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this[0].restrict_public_buckets == true
    error_message = "restrict_public_buckets is not true"
  }
}

run "versioning_configuration" {
  command = plan

  variables {
    bucket_name       = "test-bucket-versioning"
    environment       = "dev"
    enable_versioning = true
  }

  assert {
    condition     = length(aws_s3_bucket_versioning.this) > 0
    error_message = "Versioning not configured"
  }

  assert {
    condition     = length(aws_s3_bucket_versioning.this[0].versioning_configuration) > 0 && aws_s3_bucket_versioning.this[0].versioning_configuration[0].status == "Enabled"
    error_message = "Versioning status is not Enabled"
  }
}

run "disable_bucket_creation" {
  command = plan

  variables {
    bucket_name   = "test-bucket-disabled"
    environment   = "dev"
    create_bucket = false
  }

  assert {
    condition     = length(aws_s3_bucket.this) == 0
    error_message = "Bucket was created when create_bucket is false"
  }
}

run "lifecycle_rules_configuration" {
  command = plan

  variables {
    bucket_name            = "test-bucket-lifecycle"
    environment            = "dev"
    enable_lifecycle_rules = true
    lifecycle_config = {
      transition_to_ia_days           = 30
      transition_to_glacier_days      = 90
      expiration_days                 = 365
      abort_incomplete_multipart_days = 7
    }
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) > 0
    error_message = "Lifecycle configuration not created"
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this[0].rule) > 0
    error_message = "Lifecycle rules are not configured"
  }
}

run "cors_configuration" {
  command = plan

  variables {
    bucket_name = "test-bucket-cors"
    environment = "dev"
    cors_rules = [
      {
        allowed_methods = ["GET", "PUT"]
        allowed_origins = ["https://example.com"]
        allowed_headers = ["*"]
      }
    ]
  }

  assert {
    condition     = length(aws_s3_bucket_cors_configuration.this) > 0
    error_message = "CORS configuration not created"
  }

  assert {
    condition     = length(aws_s3_bucket_cors_configuration.this[0].cors_rule) > 0
    error_message = "CORS rule was not applied"
  }
}

run "logging_configuration" {
  command = plan

  variables {
    bucket_name           = "test-bucket-logging"
    environment           = "dev"
    enable_logging        = true
    logging_target_bucket = "my-logs-bucket"
    logging_target_prefix = "logs/"
  }

  assert {
    condition     = length(aws_s3_bucket_logging.this) > 0
    error_message = "Logging configuration not created"
  }

  assert {
    condition     = aws_s3_bucket_logging.this[0].target_bucket == "my-logs-bucket"
    error_message = "Target bucket is not set correctly"
  }

  assert {
    condition     = aws_s3_bucket_logging.this[0].target_prefix == "logs/"
    error_message = "Target prefix is not set correctly"
  }
}

run "bucket_name_validation" {
  command = plan

  variables {
    bucket_name = "INVALID-NAME"
    environment = "dev"
  }

  expect_failures = [
    var.bucket_name
  ]
}

run "invalid_environment" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    environment = "production"
  }

  expect_failures = [
    var.environment
  ]
}

run "tags_applied" {
  command = plan

  variables {
    bucket_name = "test-bucket-tags"
    environment = "prod"
    tags = {
      CostCenter = "Engineering"
      Owner      = "Platform Team"
    }
  }

  assert {
    condition     = aws_s3_bucket.this[0].tags["CostCenter"] == "Engineering"
    error_message = "Custom CostCenter tag not applied"
  }

  assert {
    condition     = aws_s3_bucket.this[0].tags["Owner"] == "Platform Team"
    error_message = "Custom Owner tag not applied"
  }

  assert {
    condition     = aws_s3_bucket.this[0].tags["ManagedBy"] == "Terraform"
    error_message = "ManagedBy tag not auto-applied"
  }
}

run "encryption_disabled" {
  command = plan

  variables {
    bucket_name       = "test-bucket-no-encryption"
    environment       = "dev"
    enable_encryption = false
  }

  assert {
    condition     = length(aws_s3_bucket_server_side_encryption_configuration.this) == 0
    error_message = "Encryption was applied when disabled"
  }
}
