#!/usr/bin/env python3
"""Test Terraform configuration validity"""

import subprocess
import json
import tempfile
import shutil
from pathlib import Path

def test_terraform_format():
    """Test that all Terraform files are properly formatted"""
    result = subprocess.run([
        "terraform", "fmt", "-check", "-recursive"
    ], cwd="terraform", capture_output=True, text=True)
    
    assert result.returncode == 0, f"Terraform formatting issues: {result.stdout}"

def test_terraform_validate():
    """Test that Terraform configuration is valid"""
    # Create temporary directory for validation
    import tempfile
    import shutil
    
    with tempfile.TemporaryDirectory() as temp_dir:
        # Copy terraform files to temp directory
        terraform_dir = Path("terraform")
        temp_terraform = Path(temp_dir) / "terraform"
        shutil.copytree(terraform_dir, temp_terraform)
        
        # Remove backend configuration and state for validation
        backend_file = temp_terraform / "backend.tf"
        if backend_file.exists():
            backend_file.unlink()
        
        # Remove any existing terraform state/cache
        terraform_dir_path = temp_terraform / ".terraform"
        if terraform_dir_path.exists():
            shutil.rmtree(terraform_dir_path)
        
        # Initialize and validate
        result = subprocess.run([
            "terraform", "init"
        ], cwd=temp_terraform, capture_output=True, text=True)
        
        assert result.returncode == 0, f"Terraform init failed: {result.stderr}"
        
        # Validate configuration
        result = subprocess.run([
            "terraform", "validate", "-json"
        ], cwd=temp_terraform, capture_output=True, text=True)
        
        assert result.returncode == 0, f"Terraform validation failed: {result.stderr}"
        
        validation_result = json.loads(result.stdout)
        assert validation_result["valid"] == True, "Terraform configuration is invalid"

def test_required_files_exist():
    """Test that all required Terraform files exist"""
    required_files = [
        "terraform/backend.tf",
        "terraform/providers.tf", 
        "terraform/organizations.tf",
        "terraform/service-control-policies.tf",
        "terraform/sso-permission-sets.tf"
    ]
    
    for file_path in required_files:
        assert Path(file_path).exists(), f"Required file missing: {file_path}"

if __name__ == "__main__":
    test_required_files_exist()
    test_terraform_format()
    test_terraform_validate()
    print("✅ All Terraform tests passed!")