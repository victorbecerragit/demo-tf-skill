variable "bucket_name" {
  description = "Name of the S3 bucket. Must be globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9\\-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must start and end with alphanumeric, contain only lowercase letters, numbers, and hyphens."
  }

  nullable = false
}

variable "create_bucket" {
  description = "Whether to create the S3 bucket"
  type        = bool
  default     = true

  nullable = false
}

variable "environment" {
  description = "Environment name for resource tagging (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }

  nullable = false
}

variable "enable_versioning" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = false

  nullable = false
}

variable "enable_encryption" {
  description = "Enable server-side encryption with AES256"
  type        = bool
  default     = true

  nullable = false
}

variable "enable_public_access_block" {
  description = "Enable public access block to prevent accidental public exposure"
  type        = bool
  default     = true

  nullable = false
}

variable "enable_logging" {
  description = "Enable access logging to another S3 bucket"
  type        = bool
  default     = false

  nullable = false
}

variable "logging_target_bucket" {
  description = "S3 bucket for storing access logs (required if enable_logging is true)"
  type        = string
  default     = ""

  nullable = false
}

variable "logging_target_prefix" {
  description = "Prefix for access log objects"
  type        = string
  default     = "logs/"

  nullable = false
}

variable "enable_lifecycle_rules" {
  description = "Enable lifecycle rules for object expiration and transitions"
  type        = bool
  default     = false

  nullable = false
}

variable "lifecycle_config" {
  description = "Lifecycle configuration for the S3 bucket"
  type = object({
    transition_to_ia_days           = optional(number, 30)
    transition_to_glacier_days      = optional(number, 90)
    expiration_days                 = optional(number, 365)
    abort_incomplete_multipart_days = optional(number, 7)
  })
  default = {}

  nullable = false
}

variable "force_destroy" {
  description = "Allow Terraform to destroy the bucket even if it contains objects"
  type        = bool
  default     = false

  nullable = false
}

variable "tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
  default     = {}

  nullable = false
}

variable "cors_rules" {
  description = "CORS configuration rules for the bucket"
  type = list(object({
    allowed_headers = optional(list(string), ["*"])
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, 3000)
  }))
  default = []

  nullable = false
}

variable "block_public_acls" {
  description = "Block public ACLs on the bucket"
  type        = bool
  default     = true

  nullable = false
}

variable "block_public_policy" {
  description = "Block public bucket policies on the bucket"
  type        = bool
  default     = true

  nullable = false
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs on the bucket"
  type        = bool
  default     = true

  nullable = false
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket access on the bucket"
  type        = bool
  default     = true

  nullable = false
}
