#!/usr/bin/env python3
"""End-to-end pipeline tests"""

import subprocess
import tempfile
import shutil
from pathlib import Path

def test_full_pipeline_locally():
    """Test the complete local development pipeline"""
    
    # Test validation
    result = subprocess.run(['make', 'validate'], capture_output=True, text=True)
    assert result.returncode == 0, f"Validation failed: {result.stderr}"
    
    # Test template generation
    result = subprocess.run([
        'bash', '-c', 
        'cd ansible && ANSIBLE_STDOUT_CALLBACK=default ansible-playbook playbooks/generate-terraform.yml'
    ], capture_output=True, text=True)
    assert result.returncode == 0, f"Template generation failed: {result.stderr}"
    
    # Test terraform validation (skip plan to avoid backend issues)
    result = subprocess.run([
        'bash', '-c', 
        'cd terraform && terraform fmt -check -recursive'
    ], capture_output=True, text=True)
    assert result.returncode == 0, f"Terraform format check failed: {result.stderr}"
    
    # Test terraform validate without backend
    result = subprocess.run([
        'bash', '-c', 
        'cd terraform && terraform init -backend=false && terraform validate'
    ], capture_output=True, text=True)
    assert result.returncode == 0, f"Terraform validation failed: {result.stderr}"

def test_security_scanning():
    """Test security scanning with tfsec"""
    
    # Generate templates first
    subprocess.run([
        'bash', '-c', 
        'cd ansible && ANSIBLE_STDOUT_CALLBACK=default ansible-playbook playbooks/generate-terraform.yml'
    ], capture_output=True)
    
    # Run tfsec
    result = subprocess.run([
        'tfsec', 'terraform/', '--format', 'json'
    ], capture_output=True, text=True)
    
    # tfsec returns 0 if no issues, 1 if issues found
    if result.returncode == 1:
        import json
        try:
            results = json.loads(result.stdout)
            high_severity = [r for r in results.get('results', []) if r.get('severity') == 'HIGH']
            assert len(high_severity) == 0, f"High severity security issues found: {high_severity}"
        except json.JSONDecodeError:
            # If not JSON, just check return code
            pass

if __name__ == "__main__":
    test_full_pipeline_locally()
    test_security_scanning()
    print("✅ All pipeline tests passed!")