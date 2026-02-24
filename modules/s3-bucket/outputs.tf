output "bucket_id" {
  description = "The name of the S3 bucket"
  value       = try(aws_s3_bucket.this[0].id, null)
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = try(aws_s3_bucket.this[0].arn, null)
}

output "bucket_domain_name" {
  description = "The bucket region-specific domain name"
  value       = try(aws_s3_bucket.this[0].bucket_regional_domain_name, null)
}

output "versioning_enabled" {
  description = "Whether versioning is enabled on the bucket"
  value       = var.enable_versioning
}

output "encryption_enabled" {
  description = "Whether server-side encryption is enabled"
  value       = var.enable_encryption
}

output "public_access_block" {
  description = "Public access block configuration"
  value = try(
    {
      block_public_acls       = aws_s3_bucket_public_access_block.this[0].block_public_acls
      block_public_policy     = aws_s3_bucket_public_access_block.this[0].block_public_policy
      ignore_public_acls      = aws_s3_bucket_public_access_block.this[0].ignore_public_acls
      restrict_public_buckets = aws_s3_bucket_public_access_block.this[0].restrict_public_buckets
    },
    null
  )
}
