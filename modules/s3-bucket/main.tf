# S3 Bucket
resource "aws_s3_bucket" "this" {
  count = var.create_bucket ? 1 : 0

  bucket              = var.bucket_name
  force_destroy       = var.force_destroy
  object_lock_enabled = false

  tags = merge(
    var.tags,
    {
      Name        = var.bucket_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.create_bucket && var.enable_encryption ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "this" {
  count = var.create_bucket && var.enable_versioning ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Access Logging
resource "aws_s3_bucket_logging" "this" {
  count = var.create_bucket && var.enable_logging ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_target_prefix
}

# Lifecycle Rules
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.create_bucket && var.enable_lifecycle_rules ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  rule {
    id     = "intelligent-tiering"
    status = "Enabled"

    filter {}

    # Transition to Standard-IA
    transition {
      days          = var.lifecycle_config.transition_to_ia_days
      storage_class = "STANDARD_IA"
    }

    # Transition to Glacier
    transition {
      days          = var.lifecycle_config.transition_to_glacier_days
      storage_class = "GLACIER"
    }

    # Expire old versions/objects
    expiration {
      days = var.lifecycle_config.expiration_days
    }

    # Abort incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = var.lifecycle_config.abort_incomplete_multipart_days
    }
  }
}

# CORS Configuration
resource "aws_s3_bucket_cors_configuration" "this" {
  count = var.create_bucket && length(var.cors_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  dynamic "cors_rule" {
    for_each = var.cors_rules

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

# Public Access Block
resource "aws_s3_bucket_public_access_block" "this" {
  count = var.create_bucket && var.enable_public_access_block ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# Block all public access for simplicity (alternative configuration)
# Uncomment to use instead of individual settings above
# resource "aws_s3_bucket_public_access_block" "this" {
#   count = var.create_bucket && var.enable_public_access_block ? 1 : 0

#   bucket = aws_s3_bucket.this[0].id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
