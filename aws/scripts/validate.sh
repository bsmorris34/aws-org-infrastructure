#!/bin/bash
set -e

echo "🔍 Running Infrastructure Validation..."

# Terraform validation
echo "📋 Validating Terraform configuration..."
cd terraform
terraform fmt -check -recursive
terraform validate

# Generate Ansible templates
echo "🎭 Generating Ansible templates..."
cd ../ansible
export PATH="/Users/brandon/.local/bin:$PATH"
ANSIBLE_STDOUT_CALLBACK=default ansible-playbook playbooks/generate-terraform.yml

# Validate generated files
echo "📋 Validating generated Terraform files..."
cd ../terraform
terraform validate

echo "✅ All validations passed!"