#!/bin/bash
set -e

echo "🔍 Running drift detection..."

cd terraform
export AWS_PROFILE=management-org

# Generate current templates
echo "🎭 Generating current templates..."
cd ../ansible
export PATH="/Users/brandon/.local/bin:$PATH"
ANSIBLE_STDOUT_CALLBACK=default ansible-playbook playbooks/generate-terraform.yml

cd ../terraform

# Run terraform plan to detect drift
echo "📋 Checking for infrastructure drift..."
terraform plan -detailed-exitcode

EXIT_CODE=$?

case $EXIT_CODE in
  0)
    echo "✅ No drift detected - infrastructure matches configuration"
    ;;
  1)
    echo "❌ Error occurred during drift detection"
    exit 1
    ;;
  2)
    echo "⚠️ Drift detected - infrastructure differs from configuration"
    echo "Run 'terraform plan' to see detailed changes"
    exit 2
    ;;
esac