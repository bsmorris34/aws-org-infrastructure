#!/usr/bin/env python3
"""Test Ansible template generation"""

import os
import yaml
import tempfile
import subprocess
from pathlib import Path

def test_ansible_config_valid():
    """Test that Ansible configuration is valid"""
    config_path = Path("ansible/group_vars/production.yml")
    assert config_path.exists(), "Ansible config file missing"
    
    with open(config_path) as f:
        config = yaml.safe_load(f)
    
    # Test required keys exist
    assert "aws_accounts" in config
    assert "budgets" in config
    assert "notifications" in config
    
    # Test account IDs are valid
    for account_id in config["aws_accounts"].values():
        assert len(account_id) == 12, f"Invalid account ID: {account_id}"
        assert account_id.isdigit(), f"Account ID not numeric: {account_id}"

def test_template_generation():
    """Test that templates generate valid Terraform"""
    # Run ansible playbook
    result = subprocess.run([
        "ansible-playbook", 
        "playbooks/generate-terraform.yml"
    ], cwd="ansible", capture_output=True, text=True)
    
    assert result.returncode == 0, f"Ansible failed: {result.stderr}"
    
    # Check generated file exists
    generated_file = Path("terraform/cost-management.tf")
    assert generated_file.exists(), "Generated file missing"
    
    # Validate Terraform syntax
    result = subprocess.run([
        "terraform", "validate"
    ], cwd="terraform", capture_output=True, text=True)
    
    assert result.returncode == 0, f"Terraform validation failed: {result.stderr}"

if __name__ == "__main__":
    test_ansible_config_valid()
    test_template_generation()
    print("✅ All template tests passed!")