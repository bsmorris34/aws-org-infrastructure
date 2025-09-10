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

# Integration tests
test-integration:
	@echo "🔗 Running integration tests..."
	@. venv/bin/activate && python -m pytest tests/test_integration.py -v

# Pipeline tests
test-pipeline:
	@echo "⚙️ Running pipeline tests..."
	@. venv/bin/activate && python tests/test_pipeline.py

# Disaster recovery tests
test-dr:
	@echo "🆘 Running disaster recovery tests..."
	@. venv/bin/activate && python tests/test_disaster_recovery.py

# Run all tests
test-all: test test-pipeline test-dr
	@echo "✅ All comprehensive tests passed!"

# Clean generated files
clean:
	@echo "🧹 Cleaning generated files..."
	@find . -name "*.backup*" -delete 2>/dev/null || true
	@find . -name "*.[0-9]*.[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]@[0-9][0-9]:[0-9][0-9]:[0-9][0-9]" -delete 2>/dev/null || true