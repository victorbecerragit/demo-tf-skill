# Security Best Practices for S3 Module

## Overview

This document outlines security considerations and best practices for using the S3 bucket module.

## Default Security Configuration

The module enforces security best practices by default:

### 1. ✅ Public Access Blocking
```hcl
enable_public_access_block = true  # Default
```
All public access is blocked by default. This includes:
- Block public ACLs
- Block public bucket policies
- Ignore public ACLs
- Restrict public buckets

### 2. ✅ Encryption at Rest
```hcl
enable_encryption = true  # Default
```
Server-side encryption with AES256 is enabled by default.

### 3. ✅ Input Validation
Bucket names are validated using regex to ensure compliance:
```hcl
variable "bucket_name" {
  validation {
    condition = can(regex("^[a-z0-9][a-z0-9\\-]*[a-z0-9]$", var.bucket_name))
  }
}
```

## Security Checklist

When using this module, follow these security practices:

### ☐ Access Control
- [ ] Use bucket policies to restrict access to specific principals
- [ ] Never use `s3:*` - always specify exact permissions
- [ ] Use conditions to limit by IP, VPC, or time window
- [ ] Enable MFA delete for production buckets

### ☐ Encryption
- [ ] Keep `enable_encryption = true` (default)
- [ ] For sensitive data, use KMS encryption instead of AES256
- [ ] Rotate KMS keys annually
- [ ] Enable `bucket_key_enabled` for KMS (TODO: add to module)

### ☐ Logging & Monitoring
- [ ] Enable `enable_logging = true` for production
- [ ] Separate logs to a dedicated bucket
- [ ] Enable CloudTrail for S3 data events
- [ ] Set up CloudWatch alarms for unusual access patterns

### ☐ Lifecycle & Retention
- [ ] Define lifecycle policies to delete old logs
- [ ] Use `enable_versioning = true` for mission-critical data
- [ ] Set retention policies for compliance requirements
- [ ] Regularly audit object permissions

### ☐ Network Security
- [ ] Use VPC endpoints for S3 access from EC2
- [ ] Restrict bucket access by IP using bucket policies
- [ ] Use SSL/TLS for all data in transit
- [ ] Block unencrypted uploads with `ssl-required` policy

## IAM Policies - Example

### Least-Privilege Read Access
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "IAM": "arn:aws:iam::ACCOUNT:user/appuser"
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ]
    }
  ]
}
```

### Require Encryption
```json
{
  "Effect": "Deny",
  "Principal": "*",
  "Action": "s3:PutObject",
  "Resource": "arn:aws:s3:::my-bucket/*",
  "Condition": {
    "StringNotEquals": {
      "s3:x-amz-server-side-encryption": "AES256"
    }
  }
}
```

### IP Restriction
```json
{
  "Effect": "Allow",
  "Principal": "*",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::my-bucket/*",
  "Condition": {
    "IpAddress": {
      "aws:SourceIp": [
        "203.0.113.0/24"
      ]
    }
  }
}
```

## Sensitive Configuration Recommendations

For highly sensitive S3 buckets, consider:

1. **Enable Versioning + MFA Delete**
   ```hcl
   enable_versioning = true
   mfa_delete = true  # Requires MFA to permanently delete
   ```

2. **Use KMS Encryption** (requires custom configuration)
   ```hcl
   # Add to module
   kms_key_arn = aws_kms_key.s3.arn
   ```

3. **Enable Access Logging + CloudTrail**
   ```hcl
   enable_logging = true
   logging_target_bucket = aws_s3_bucket.logs.id
   ```

4. **Restrict via VPC Endpoint**
   ```hcl
   require_vpc_endpoint = true
   ```

5. **Implement Object Lock** (for compliance)
   ```hcl
   # TODO: Add to module
   object_lock_enabled = true
   ```

## Compliance Requirements

### GDPR
- ✅ Encryption at rest (AES256)
- ✅ Access logging
- ☐ TODO: Add IP whitelisting
- ☐ TODO: Add object expiration

### HIPAA
- ☐ Requires KMS encryption (not default)
- ☐ Requires MFA delete
- ✅ Access logging supported
- ☐ TODO: Add encryption key rotation

### PCI DSS
- ✅ Encryption at rest (AES256)
- ✅ Public access blocking
- ✅ Access logging
- ☐ TODO: Add encryption in transit requirement

## Security Scanning

The CI/CD pipeline scans for security issues:

### Trivy
Scans for known vulnerabilities and misconfigurations:
```bash
trivy config modules/s3-bucket/
```

### Checkov
Validates IaC security policies:
```bash
checkov -d modules/s3-bucket/ --framework terraform
```

## Vulnerability Response

If a vulnerability is found:

1. **Assess Impact** - Review security scan details
2. **Review Code** - Check the offending resource configuration
3. **Patch Module** - Update module with security fix
4. **Test Changes** - Run full test suite
5. **Deploy** - Merge and deploy to affected buckets

## Secrets Management

### ❌ DON'T
- Store AWS keys in Terraform variables
- Commit credentials to version control
- Email sensitive data
- Log sensitive values

### ✅ DO
- Use AWS Secrets Manager for sensitive values
- Use AWS Systems Manager Parameter Store for configs
- Use `sensitive = true` in outputs
- Rotate credentials regularly

## Data Classification

Consider your data sensitivity:

| Classification | Recommendation |
|---|---|
| Public | Default settings OK, no versioning needed |
| Internal | Enable public access blocking, consider versioning |
| Confidential | Enable encryption, logging, versioning + lifecycle |
| Restricted | KMS encryption, MFA delete, IP restriction |

## Regular Security Reviews

Perform quarterly reviews:

- [ ] Audit bucket permissions
- [ ] Review access logs for anomalies
- [ ] Rotate KMS keys
- [ ] Update lifecycle policies
- [ ] Check for unencrypted objects
- [ ] Verify public access is blocked
- [ ] Review bucket policies for overly broad access

## Incident Response

If unauthorized access is suspected:

1. **Enable CloudTrail** to identify who accessed what
2. **Review Logs** in the logs bucket
3. **Rotate Credentials** if keys are compromised
4. **Update Policies** to prevent future access
5. **Alert Team** and follow your incident response plan

## Additional Resources

- [AWS S3 Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/BestPractices.html)
- [OWASP Cloud Security Top 10](https://owasp.org/www-project-cloud-top-10/)
- [AWS Well-Architected Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
