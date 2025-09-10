#!/usr/bin/env python3
"""Integration tests for deployed AWS resources"""

import boto3
import pytest
from botocore.exceptions import ClientError

class TestAWSIntegration:
    
    def setup_method(self):
        """Setup AWS clients"""
        self.org_client = boto3.client('organizations')
        self.sso_client = boto3.client('sso-admin')
        self.sns_client = boto3.client('sns')
        self.budgets_client = boto3.client('budgets')
        
    def test_organizational_units_exist(self):
        """Test that OUs are created and structured correctly"""
        response = self.org_client.list_organizational_units_for_parent(
            ParentId=self.org_client.list_roots()['Roots'][0]['Id']
        )
        
        ou_names = [ou['Name'] for ou in response['OrganizationalUnits']]
        
        assert 'Security' in ou_names
        assert 'Workloads' in ou_names
        # Note: Bramco OU may not be deployed yet
        
    def test_service_control_policies_attached(self):
        """Test that SCPs are created and attached"""
        policies = self.org_client.list_policies(Filter='SERVICE_CONTROL_POLICY')
        policy_names = [p['Name'] for p in policies['Policies']]
        
        expected_policies = [
            'PreventRootUserAccess',
            'RestrictRegions', 
            'ProductionControls'
        ]
        
        for policy in expected_policies:
            assert policy in policy_names
            
    def test_sso_permission_sets_exist(self):
        """Test that SSO permission sets are created"""
        instances = self.sso_client.list_instances()
        instance_arn = instances['Instances'][0]['InstanceArn']
        
        permission_sets = self.sso_client.list_permission_sets(
            InstanceArn=instance_arn
        )
        
        # Get permission set details
        ps_details = []
        for ps_arn in permission_sets['PermissionSets']:
            details = self.sso_client.describe_permission_set(
                InstanceArn=instance_arn,
                PermissionSetArn=ps_arn
            )
            ps_details.append(details['PermissionSet']['Name'])
            
        assert 'InfrastructureAdmin' in ps_details
        assert 'ApplicationDeployer' in ps_details
        assert 'ReadOnlyAuditor' in ps_details
        
    def test_sns_topic_exists_and_encrypted(self):
        """Test that SNS topic exists and is encrypted"""
        try:
            response = self.sns_client.get_topic_attributes(
                TopicArn='arn:aws:sns:us-east-1:396913723725:budget-alerts'
            )
            
            # Check encryption is enabled
            assert 'KmsMasterKeyId' in response['Attributes']
            assert response['Attributes']['KmsMasterKeyId'] != ''
            
        except ClientError as e:
            pytest.fail(f"SNS topic not found or accessible: {e}")
            
    def test_budgets_exist(self):
        """Test that budgets are created"""
        try:
            budgets = self.budgets_client.describe_budgets(
                AccountId='396913723725'
            )
            
            budget_names = [b['BudgetName'] for b in budgets['Budgets']]
            
            assert 'organization-monthly-budget' in budget_names
            assert 'dev-account-budget' in budget_names
            assert 'staging-account-budget' in budget_names
            assert 'prod-account-budget' in budget_names
            
        except ClientError as e:
            pytest.fail(f"Budgets not accessible: {e}")

if __name__ == "__main__":
    pytest.main([__file__, "-v"])