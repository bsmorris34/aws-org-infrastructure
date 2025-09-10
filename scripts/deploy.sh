#!/bin/bash
set -e

ENVIRONMENT=${1:-"production"}

echo "🚀 Deploying to $ENVIRONMENT environment..."

# Validate first
echo "🔍 Running validation..."
./scripts/validate.sh

# Generate templates
echo "🎭 Generating templates..."
cd ansible
export PATH="/Users/brandon/.local/bin:$PATH"
ANSIBLE_STDOUT_CALLBACK=default ansible-playbook playbooks/generate-terraform.yml

# Deploy infrastructure
echo "🏗️ Deploying infrastructure..."
cd ../terraform

# Set AWS profile based on environment
case $ENVIRONMENT in
  "production")
    export AWS_PROFILE=management-org
    ;;
  "staging")
    export AWS_PROFILE=management-org
    ;;
  *)
    echo "❌ Unknown environment: $ENVIRONMENT"
    exit 1
    ;;
esac

# Plan and apply
terraform plan -out=tfplan
echo "📋 Plan generated. Applying in 5 seconds..."
sleep 5
terraform apply tfplan
rm tfplan

echo "✅ Deployment completed successfully!"