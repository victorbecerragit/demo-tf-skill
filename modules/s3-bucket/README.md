# S3 Bucket Module

A production-grade Terraform module for provisioning secure AWS S3 buckets with optional versioning, encryption, lifecycle policies, and access controls.

## Features

- ✅ **Security First**: Public access blocking, encryption, and server-side configuration
- ✅ **Lifecycle Management**: Intelligent tiering and automatic cleanup
- ✅ **Versioning Support**: Object version control with configurable retention
- ✅ **Access Logging**: Optional S3 access logs to detect unauthorized attempts
- ✅ **CORS Support**: Configurable cross-origin resource sharing
- ✅ **Cost Optimization**: Automatic transitions to cheaper storage classes
- ✅ **Environment-Aware**: Support for dev, staging, and production environments

## Usage

### Minimal Example

```hcl
module "s3_bucket" {
  source = "./modules/s3-bucket"

  bucket_name = "my-app-bucket"
  environment = "dev"
}
```

### Production Example

```hcl
module "s3_bucket" {
  source = "./modules/s3-bucket"

  bucket_name = "my-app-production-bucket"
  environment = "prod"

  enable_versioning = true
  enable_encryption = true
  enable_logging    = true

  logging_target_bucket = aws_s3_bucket.logs.id
  logging_target_prefix = "access-logs/"

  enable_lifecycle_rules = true
  lifecycle_config = {
    transition_to_ia_days      = 30
    transition_to_glacier_days = 90
    expiration_days            = 365
  }

  cors_rules = [
    {
      allowed_methods = ["GET", "PUT", "POST"]
      allowed_origins = ["https://example.com"]
      allowed_headers = ["*"]
      expose_headers  = ["Content-Length"]
      max_age_seconds = 3600
    }
  ]

  tags = {
    CostCenter = "engineering"
    Owner      = "platform-team"
  }
}
```

## Module Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `bucket_name` | `string` | Required | S3 bucket name (must be globally unique) |
| `create_bucket` | `bool` | `true` | Whether to create the S3 bucket |
| `environment` | `string` | `"dev"` | Environment: dev, staging, or prod |
| `enable_versioning` | `bool` | `false` | Enable version control |
| `enable_encryption` | `bool` | `true` | Enable AES256 encryption |
| `enable_public_access_block` | `bool` | `true` | Block all public access |
| `enable_logging` | `bool` | `false` | Enable access logging |
| `logging_target_bucket` | `string` | `""` | Target bucket for logs |
| `logging_target_prefix` | `string` | `"logs/"` | Prefix for log objects |
| `enable_lifecycle_rules` | `bool` | `false` | Enable lifecycle policies |
| `lifecycle_config` | `object` | `{}` | Lifecycle configuration |
| `force_destroy` | `bool` | `false` | Allow destroying non-empty buckets |
| `cors_rules` | `list(object)` | `[]` | CORS configuration |
| `tags` | `map(string)` | `{}` | Additional tags |

## Module Outputs

| Name | Description |
|------|-------------|
| `bucket_id` | S3 bucket name |
| `bucket_arn` | S3 bucket ARN |
| `bucket_domain_name` | Regional domain name for the bucket |
| `bucket_website_endpoint` | Website endpoint URL |
| `versioning_enabled` | Whether versioning is enabled |
| `encryption_enabled` | Whether encryption is enabled |
| `public_access_block` | Public access block configuration |

## Security Considerations

### Default Configuration

This module enforces security best practices by default:

- **Public Access Blocking**: All public access is blocked by default
- **Encryption**: AES256 encryption is enabled by default
- **Validation**: Bucket name validation prevents invalid names

### Least Privilege

Always specify appropriate lifecycle rules and access policies at the bucket policy level (not included in this module to keep it focused).

### Cost Optimization

Use lifecycle rules in production to automatically transition objects to cheaper storage classes:

```hcl
lifecycle_config = {
  transition_to_ia_days      = 30    # Standard-IA after 30 days
  transition_to_glacier_days = 90    # Glacier after 90 days
  expiration_days            = 365   # Delete after 1 year
}
```

This can reduce costs by 80%+ for infrequently accessed data.

### Estimated Monthly Costs

For 100 GB of data with lifecycle enabled:

```
Standard Storage:     $0 (no cost for first month)
Standard-IA:          $0.125 per GB × 30 GB = $3.75
Glacier:              $0.004 per GB × 40 GB = $0.16
(Remaining 30 GB newer data in Standard)

Total:  ~$10/month (vs $2.30 for Standard-only)
```

## Testing

The module includes comprehensive tests using Terraform native testing framework (1.6+):

```bash
terraform test

# Specific test file
terraform test -test-directory=./tests
```

### Test Coverage

- ✅ Module configuration validation
- ✅ Security settings enforcement
- ✅ Lifecycle rule correctness
- ✅ Optional features (versioning, encryption, logging)
- ✅ CORS rule configuration
- ✅ Public access block setup

## Troubleshooting

### Bucket Name Already Exists

S3 bucket names are globally unique. Choose a name with a unique prefix like:

```hcl
bucket_name = "mycompany-${data.aws_caller_identity.current.account_id}-app-data"
```

### Cannot Destroy Non-Empty Bucket

Set `force_destroy = true` to allow Terraform to delete buckets with objects:

```hcl
force_destroy = true
```

### Logging Target Bucket Not Found

Ensure the target logging bucket exists first:

```hcl
# Create logs bucket first
module "logs_bucket" {
  source = "./modules/s3-bucket"
  bucket_name = "${var.bucket_name}-logs"
}

# Reference in main bucket
module "main_bucket" {
  source = "./modules/s3-bucket"
  bucket_name = var.bucket_name

  enable_logging        = true
  logging_target_bucket = module.logs_bucket.bucket_id
}
```

## License

Apache License 2.0

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Block public ACLs on the bucket | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Block public bucket policies on the bucket | `bool` | `true` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the S3 bucket. Must be globally unique. | `string` | n/a | yes |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | CORS configuration rules for the bucket | <pre>list(object({<br/>    allowed_headers = optional(list(string), ["*"])<br/>    allowed_methods = list(string)<br/>    allowed_origins = list(string)<br/>    expose_headers  = optional(list(string), [])<br/>    max_age_seconds = optional(number, 3000)<br/>  }))</pre> | `[]` | no |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket) | Whether to create the S3 bucket | `bool` | `true` | no |
| <a name="input_enable_encryption"></a> [enable\_encryption](#input\_enable\_encryption) | Enable server-side encryption with AES256 | `bool` | `true` | no |
| <a name="input_enable_lifecycle_rules"></a> [enable\_lifecycle\_rules](#input\_enable\_lifecycle\_rules) | Enable lifecycle rules for object expiration and transitions | `bool` | `false` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Enable access logging to another S3 bucket | `bool` | `false` | no |
| <a name="input_enable_public_access_block"></a> [enable\_public\_access\_block](#input\_enable\_public\_access\_block) | Enable public access block to prevent accidental public exposure | `bool` | `true` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Enable versioning on the S3 bucket | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name for resource tagging (dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Allow Terraform to destroy the bucket even if it contains objects | `bool` | `false` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Ignore public ACLs on the bucket | `bool` | `true` | no |
| <a name="input_lifecycle_config"></a> [lifecycle\_config](#input\_lifecycle\_config) | Lifecycle configuration for the S3 bucket | <pre>object({<br/>    transition_to_ia_days           = optional(number, 30)<br/>    transition_to_glacier_days      = optional(number, 90)<br/>    expiration_days                 = optional(number, 365)<br/>    abort_incomplete_multipart_days = optional(number, 7)<br/>  })</pre> | `{}` | no |
| <a name="input_logging_target_bucket"></a> [logging\_target\_bucket](#input\_logging\_target\_bucket) | S3 bucket for storing access logs (required if enable\_logging is true) | `string` | `""` | no |
| <a name="input_logging_target_prefix"></a> [logging\_target\_prefix](#input\_logging\_target\_prefix) | Prefix for access log objects | `string` | `"logs/"` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Restrict public bucket access on the bucket | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the S3 bucket | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the S3 bucket |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | The bucket region-specific domain name |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | The name of the S3 bucket |
| <a name="output_encryption_enabled"></a> [encryption\_enabled](#output\_encryption\_enabled) | Whether server-side encryption is enabled |
| <a name="output_public_access_block"></a> [public\_access\_block](#output\_public\_access\_block) | Public access block configuration |
| <a name="output_versioning_enabled"></a> [versioning\_enabled](#output\_versioning\_enabled) | Whether versioning is enabled on the bucket |
<!-- END_TF_DOCS -->
