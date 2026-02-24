# Testing Guide for S3 Module

## Overview

This module includes comprehensive testing at multiple levels:

1. **Static Analysis** - Format, validation, linting
2. **Native Tests** - Terraform 1.6+ native test framework
3. **Security Scanning** - Trivy and Checkov
4. **Integration Testing** - Real AWS resources (examples/)

## Quick Start

### Prerequisites

```bash
# Terraform 1.6+
terraform version

# Optional: TFLint for linting
brew install tflint  # macOS
choco install tflint # Windows
```

### Run Tests Locally

```bash
# Navigate to module directory
cd modules/s3-bucket

# Initialize Terraform (no backend needed for tests)
terraform init -backend=false

# Run native tests
terraform test -verbose

# Or run specific test
terraform test -test-directory=./tests -verbose
```

## Test Coverage

### Native Tests (`tests/module_test.tftest.hcl`)

The native test file includes 13 test cases covering:

#### ✅ Core Functionality
- **basic_bucket_creation**: Validates basic bucket with correct name and tags
- **tags_applied**: Confirms custom tags and auto-applied tags are set

#### 🔐 Security
- **encryption_enabled_by_default**: Verifies AES256 encryption
- **encryption_disabled**: Confirms encryption can be disabled
- **public_access_block_enabled**: Validates all PAB settings are applied

#### 🔄 Features
- **versioning_configuration**: Confirms versioning can be enabled
- **lifecycle_rules_configuration**: Validates lifecycle policy structure
- **cors_configuration**: Tests CORS rule application
- **logging_configuration**: Validates logging bucket/prefix setup

#### ❌ Error Handling
- **bucket_name_validation**: Tests invalid bucket name rejection
- **invalid_environment**: Tests invalid environment variable rejection
- **disable_bucket_creation**: Confirms create_bucket = false works

## Testing Strategy Framework (Per SKILL.md)

### Decision Matrix Applied Here

| Scenario | Approach | Tool |
|----------|----------|------|
| Quick syntax check | Static analysis | `terraform validate`, `fmt` |
| Pre-commit validation | Static + lint | validate, tflint |
| Terraform 1.6+ | Native test framework | **Built-in `terraform test`** ✅ |
| Security/compliance | Policy as code | Trivy, Checkov |
| Full integration | Real resources | examples/ directories |

## Running All Tests Locally

```bash
#!/bin/bash
# test-all.sh

set -e

echo "=== Running Format Check ==="
terraform fmt -check -recursive .

echo "=== Running Validation ==="
cd modules/s3-bucket && terraform init -backend=false && terraform validate

echo "=== Running TFLint ==="
cd ../../ && tflint --format compact .

echo "=== Running Native Tests ==="
cd modules/s3-bucket && terraform test -verbose

echo "=== Running Security Scan ==="
cd ../../ && trivy config .

echo "✅ All tests passed!"
```

## Integration Testing with Examples

The `examples/` directories serve dual purposes:
1. **Documentation** - Show real usage patterns
2. **Integration Tests** - Validate module works end-to-end

### Test Minimal Example

```bash
cd examples/minimal

# Plan (dry-run)
terraform init -backend=false
terraform plan -out=test.tfplan

# Verify plan is valid
terraform show test.tfplan

# Clean up
rm -rf .terraform test.tfplan
```

### Test Complete Example

```bash
cd examples/complete

# Plan with real variables
terraform init -backend=false
terraform plan \
  -var="environment=dev" \
  -var="cors_enabled=true" \
  -out=test.tfplan

# Verify outputs
terraform show test.tfplan | grep -E "outputs:|bucket_id|bucket_arn"

# Clean up
rm -rf .terraform test.tfplan
```

## CI/CD Testing

The GitHub Actions workflow (`.github/workflows/terraform-ci.yml`) runs:

### Stage 1: Validation & Linting
```yaml
- terraform fmt -check
- terraform validate
- tflint
```

### Stage 2: Security Scanning
```yaml
- Trivy (container/config scanning)
- Checkov (IaC security policies)
```

### Stage 3: Native Tests
```yaml
- terraform test -verbose  (all 13 tests)
```

### Stage 4: Cost Estimation
```yaml
- Infracost breakdown (monthly cost estimates)
```

### Stage 5: Plan Generation
```yaml
- terraform plan (for PR comments)
```

## Test Failure Diagnosis

### Common Issues

#### ❌ Test Command Not Found
```
Error: terraform test is not available
```
**Solution**: Upgrade to Terraform 1.6+
```bash
brew install terraform@1.6  # macOS
wget https://releases.hashicorp.com/terraform/1.6.4/terraform_1.6.4_linux_amd64.zip  # Linux
```

#### ❌ Provider Schema Not Available
```
Error: testing requires provider to be installed
```
**Solution**: Initialize before testing
```bash
cd modules/s3-bucket
terraform init -backend=false
terraform test
```

#### ❌ Invalid Variable Validation Test
```
Error: values don't match schema
```
**Solution**: Ensure test variables follow variable constraints in `variables.tf`

#### ❌ Resource Not Tracking State
```
Error: aws_s3_bucket.this[0] not found
```
**Solution**: Confirm resource is in the state by running `terraform plan` first

## Adding New Tests

To add a new test case, follow this pattern:

```hcl
run "test_description" {
  command = plan  # or 'apply' for computed values

  variables {
    bucket_name = "test-bucket-feature"
    # Set variables for this test
  }

  # Assert expected behavior
  assert {
    condition     = <condition>
    error_message = "Explanation of why assertion failed"
  }

  # Example: Test timeout handling
  # expect_failures = [
  #   aws_s3_bucket.this[0].timeout
  # ]
}
```

### Test Naming Convention

Use descriptive names:
- ✅ `basic_bucket_creation`
- ✅ `encryption_enabled_by_default`
- ❌ `test1`, `test_bucket`, `feature`

## Cost Estimation Testing

Infracost provides cost estimates without running real infrastructure:

```bash
# Install Infracost
brew install infracost  # macOS

# Generate estimate
cd examples/complete
terraform plan -out=tfplan
infracost breakdown --path tfplan

# Output shows:
# - Monthly cost per resource
# - Total infrastructure cost
# - Breakdown by cost category
```

### Example Output

```
 Name                                           Monthly Qty  Unit                 Monthly Cost

 aws_s3_bucket.this[0]
 ├─ Storage (first 50TB)                           100  GB                          $2.30
 └─ PUT requests (per 1000)                        100  per 1000                    $0.50

 aws_s3_bucket_lifecycle_configuration.this[0]
 └─ Lifecycle rules                                  1  rule                        $0.00

 TOTAL MONTHLY COST                                                                  $2.80
```

## Test Artifacts

The CI pipeline saves artifacts for debugging:

### Saved Artifacts
- `terraform-plans/` - Plan JSON and binary files
- `cost-estimates/` - Infracost JSON output
- `security-reports/` - SARIF files from Trivy/Checkov

### Download Reports
```bash
# In GitHub Actions
1. Go to workflow run
2. Click "Artifacts" section
3. Download desired artifact
```

## Resources

- [Terraform Testing Docs](https://developer.hashicorp.com/terraform/language/teststests)
- [Terraform Best Practices](https://terraform-best-practices.com/)
- [AWS S3 Docs](https://docs.aws.amazon.com/s3/)
- [Infracost Documentation](https://www.infracost.io/docs/)
- [Checkov Policy Reference](https://www.checkov.io/policies)

## Support

For test failures or questions:
1. Check this guide
2. Review output of `terraform test -verbose`
3. Check GitHub Actions logs in pull request
4. Ensure Terraform version >= 1.6.0
