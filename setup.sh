#!/bin/bash
# setup.sh - Quick setup script for S3 module development

set -e

echo "🚀 Setting up Terraform S3 Module Testing Environment"
echo ""

# Check Terraform version
echo "📋 Checking Terraform version..."
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not found. Please install Terraform 1.6+"
    echo "   Visit: https://www.terraform.io/downloads"
    exit 1
fi

TF_VERSION=$(terraform version | grep Terraform | awk '{print $2}' | sed 's/v//')
echo "✅ Terraform $TF_VERSION installed"

# Optional: Setup pre-commit
echo ""
echo "📝 Setting up pre-commit hooks (optional)..."
if command -v pre-commit &> /dev/null; then
    pre-commit install
    echo "✅ Pre-commit hooks installed"
else
    echo "⚠️  pre-commit not installed. Install with: brew install pre-commit"
fi

# Optional: Setup TFLint
echo ""
echo "🔍 Setting up TFLint (optional)..."
if command -v tflint &> /dev/null; then
    echo "✅ TFLint installed"
else
    echo "⚠️  TFLint not installed. Install with: brew install tflint"
fi

# Optional: Setup Infracost
echo ""
echo "💰 Setting up Infracost (optional)..."
if command -v infracost &> /dev/null; then
    echo "✅ Infracost installed"
else
    echo "⚠️  Infracost not installed. Install with: brew install infracost"
fi

# Test module initialization
echo ""
echo "🧪 Testing module initialization..."
cd modules/s3-bucket
terraform init -backend=false > /dev/null 2>&1
echo "✅ Module initialized"
cd ../..

# Run quick validation
echo ""
echo "✅ Running quick validation..."
cd modules/s3-bucket
terraform validate > /dev/null 2>&1
echo "✅ Module validation passed"
cd ../..

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ Setup complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "🎯 Next steps:"
echo ""
echo "1. Run local tests:"
echo "   cd modules/s3-bucket"
echo "   terraform test -verbose"
echo ""
echo "2. Try minimal example:"
echo "   cd examples/minimal"
echo "   terraform plan"
echo ""
echo "3. Try complete example:"
echo "   cd examples/complete"
echo "   terraform plan"
echo ""
echo "4. Check costs:"
echo "   cd examples/complete"
echo "   terraform plan -out=tfplan"
echo "   infracost breakdown --path tfplan"
echo ""
echo "📚 For more details, see:"
echo "   - README.md (overview)"
echo "   - TESTING.md (testing guide)"
echo "   - SECURITY.md (security best practices)"
echo ""
echo "📖 Module documentation:"
echo "   - modules/s3-bucket/README.md"
echo ""
