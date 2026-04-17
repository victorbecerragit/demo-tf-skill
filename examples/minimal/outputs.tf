output "bucket_id" {
  value       = module.s3_bucket_minimal.bucket_id
  description = "The S3 bucket ID"
}

output "bucket_arn" {
  value       = module.s3_bucket_minimal.bucket_arn
  description = "The S3 bucket ARN"
}
