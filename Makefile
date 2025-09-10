.PHONY: help setup validate plan apply destroy test clean

# Default target
help:
	@echo "Available targets:"
	@echo "  setup     - Set up Python virtual environment"
	@echo "  validate  - Validate Terraform and Ansible configurations"
	@echo "  plan      - Generate and show Terraform execution plan"
	@echo "  apply     - Apply Terraform configuration"
	@echo "  destroy   - Destroy Terraform-managed infrastructure"
	@echo "  test      - Run all tests"
	@echo "  clean     - Clean generated files"

# Setup virtual environment
setup:
	@echo "🔧 Setting up Python virtual environment..."
	@python3 -m venv venv
	@. venv/bin/activate && pip install -r requirements.txt
	@echo "✅ Setup complete! Run 'source venv/bin/activate' to activate."

# Validation
validate:
	@echo "🔍 Running validation..."
	@./scripts/validate.sh

# Generate templates and plan
plan: validate
	@echo "📋 Generating Terraform plan..."
	@cd ansible && export PATH="/Users/brandon/.local/bin:$$PATH" && \
		ANSIBLE_STDOUT_CALLBACK=default ansible-playbook playbooks/generate-terraform.yml
	@cd terraform && terraform plan

# Apply infrastructure
apply: validate
	@echo "🚀 Applying infrastructure..."
	@cd ansible && export PATH="/Users/brandon/.local/bin:$$PATH" && \
		ANSIBLE_STDOUT_CALLBACK=default ansible-playbook playbooks/generate-terraform.yml
	@cd terraform && terraform apply

# Destroy infrastructure
destroy:
	@echo "💥 Destroying infrastructure..."
	@cd terraform && terraform destroy

# Run tests
test: validate
	@echo "🧪 Running tests..."
	@. venv/bin/activate && python tests/test_ansible_templates.py
	@. venv/bin/activate && pytest tests/ -v
	@echo "✅ All tests passed!"

# Clean generated files
clean:
	@echo "🧹 Cleaning generated files..."
	@rm -f terraform/cost-management.tf.backup*