variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "bucket_prefix" {
  description = "Prefix for bucket names"
  type        = string
  default     = "myapp"

  validation {
    condition     = length(var.bucket_prefix) > 0 && length(var.bucket_prefix) <= 20
    error_message = "Prefix must be between 1 and 20 characters."
  }
}

variable "cors_enabled" {
  description = "Enable CORS rules"
  type        = bool
  default     = true
}

variable "allowed_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["https://example.com", "https://app.example.com"]
}

variable "force_destroy" {
  description = "Allow destroying buckets with objects"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project    = "MyApp"
    CreatedBy  = "Terraform"
    CostCenter = "Engineering"
  }
}
