#!/usr/bin/env python3
"""Disaster recovery and rollback tests"""

import boto3
import json
from botocore.exceptions import ClientError

def test_terraform_state_backup():
    """Test that Terraform state is properly backed up"""
    s3_client = boto3.client('s3')
    
    # Check state file exists
    try:
        response = s3_client.head_object(
            Bucket='bramco-terraform-state-3725',
            Key='aws-organization/terraform.tfstate'
        )
        assert response['ResponseMetadata']['HTTPStatusCode'] == 200
        
    except ClientError:
        assert False, "Terraform state file not found in S3"
    
    # Check versioning is enabled
    versioning = s3_client.get_bucket_versioning(
        Bucket='bramco-terraform-state-3725'
    )
    assert versioning.get('Status') == 'Enabled', "S3 versioning not enabled"
    
    # Check encryption
    encryption = s3_client.get_bucket_encryption(
        Bucket='bramco-terraform-state-3725'
    )
    assert 'Rules' in encryption['ServerSideEncryptionConfiguration']

def test_state_locking():
    """Test that state locking is working"""
    dynamodb = boto3.client('dynamodb')
    
    # Check DynamoDB table exists
    try:
        response = dynamodb.describe_table(
            TableName='terraform-state-lock'
        )
        assert response['Table']['TableStatus'] == 'ACTIVE'
        
    except ClientError:
        assert False, "DynamoDB state lock table not found"

def test_iam_role_permissions():
    """Test that GitHubActionsRole has necessary permissions"""
    iam_client = boto3.client('iam')
    
    # Get attached policies
    response = iam_client.list_attached_role_policies(
        RoleName='GitHubActionsRole'
    )
    
    policy_arns = [p['PolicyArn'] for p in response['AttachedPolicies']]
    
    required_policies = [
        'arn:aws:iam::aws:policy/AWSOrganizationsFullAccess',
        'arn:aws:iam::aws:policy/IAMFullAccess',
        'arn:aws:iam::aws:policy/AmazonS3FullAccess',
        'arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess'
    ]
    
    for policy in required_policies:
        assert policy in policy_arns, f"Required policy not attached: {policy}"

def test_backup_and_restore_procedure():
    """Test backup and restore documentation exists"""
    from pathlib import Path
    
    # Check that disaster recovery docs exist
    docs_path = Path("docs")
    
    # Should have deployment guide
    assert (docs_path / "DEPLOYMENT.md").exists(), "Deployment documentation missing"
    
    # Check README has disaster recovery info
    readme_path = Path("README.md")
    assert readme_path.exists(), "README.md missing"
    
    with open(readme_path) as f:
        content = f.read()
        assert "destroy" in content.lower(), "Destroy procedure not documented"

if __name__ == "__main__":
    test_terraform_state_backup()
    test_state_locking()
    test_iam_role_permissions()
    test_backup_and_restore_procedure()
    print("✅ All disaster recovery tests passed!")