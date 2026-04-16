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
