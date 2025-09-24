# Get SSO instance
data "aws_ssoadmin_instances" "main" {}

# Get Brandon user from Identity Center
data "aws_identitystore_user" "brandon" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = "Brandon"
    }
  }
}

# InfrastructureAdmin Permission Set
resource "aws_ssoadmin_permission_set" "infrastructure_admin" {
  name             = "InfrastructureAdmin"
  description      = "Full infrastructure management access"
  instance_arn     = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  session_duration = "PT8H" # 8 hours
}

# Attach AWS managed policies to InfrastructureAdmin
resource "aws_ssoadmin_managed_policy_attachment" "infrastructure_admin_ec2" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.infrastructure_admin.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "infrastructure_admin_vpc" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.infrastructure_admin.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "infrastructure_admin_s3" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.infrastructure_admin.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "infrastructure_admin_iam" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.infrastructure_admin.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "infrastructure_admin_cloudwatch" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.infrastructure_admin.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "infrastructure_admin_apigateway" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
  permission_set_arn = aws_ssoadmin_permission_set.infrastructure_admin.arn
}

# Assign Brandon to InfrastructureAdmin in Management Account
resource "aws_ssoadmin_account_assignment" "brandon_infra_mgmt" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.infrastructure_admin.arn
  principal_id       = data.aws_identitystore_user.brandon.user_id
  principal_type     = "USER"
  target_id          = "396913723725" # management account
  target_type        = "AWS_ACCOUNT"
}

# Assign Brandon to InfrastructureAdmin in Dev Account
resource "aws_ssoadmin_account_assignment" "brandon_infra_dev" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.infrastructure_admin.arn
  principal_id       = data.aws_identitystore_user.brandon.user_id
  principal_type     = "USER"
  target_id          = "688567306703" # dev account
  target_type        = "AWS_ACCOUNT"
}

# Assign Brandon to InfrastructureAdmin in Staging Account
resource "aws_ssoadmin_account_assignment" "brandon_infra_staging" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.infrastructure_admin.arn
  principal_id       = data.aws_identitystore_user.brandon.user_id
  principal_type     = "USER"
  target_id          = "400205986141" # staging account
  target_type        = "AWS_ACCOUNT"
}

# Assign Brandon to InfrastructureAdmin in Prod Account
resource "aws_ssoadmin_account_assignment" "brandon_infra_prod" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.infrastructure_admin.arn
  principal_id       = data.aws_identitystore_user.brandon.user_id
  principal_type     = "USER"
  target_id          = "825765407025" # prod account
  target_type        = "AWS_ACCOUNT"
}

# ApplicationDeployer Permission Set
resource "aws_ssoadmin_permission_set" "application_deployer" {
  name             = "ApplicationDeployer"
  description      = "Application deployment and management access"
  instance_arn     = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  session_duration = "PT4H" # 4 hours
}

# Attach AWS managed policies to ApplicationDeployer
resource "aws_ssoadmin_managed_policy_attachment" "app_deployer_lambda" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.application_deployer.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "app_deployer_apigateway" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
  permission_set_arn = aws_ssoadmin_permission_set.application_deployer.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "app_deployer_dynamodb" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.application_deployer.arn
}

# Custom inline policy for ApplicationDeployer - minimal IAM permissions for Lambda deployment
resource "aws_ssoadmin_permission_set_inline_policy" "app_deployer_iam_policy" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.application_deployer.arn
  
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaRoleManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies"
        ]
        Resource = [
          "arn:aws:iam::*:role/bramco-*-lambda-*",
          "arn:aws:iam::*:role/lambda-*"
        ]
      },
      {
        Sid    = "AllowManagedPolicyAccess"
        Effect = "Allow"
        Action = [
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions"
        ]
        Resource = [
          "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
          "arn:aws:iam::aws:policy/AWSLambdaExecute"
        ]
      }
    ]
  })
}

# Assign Brandon to ApplicationDeployer in Management Account
resource "aws_ssoadmin_account_assignment" "brandon_app_mgmt" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.application_deployer.arn
  principal_id       = data.aws_identitystore_user.brandon.user_id
  principal_type     = "USER"
  target_id          = "396913723725" # management account
  target_type        = "AWS_ACCOUNT"
}

# Assign Brandon to ApplicationDeployer in Dev Account
resource "aws_ssoadmin_account_assignment" "brandon_app_dev" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.application_deployer.arn
  principal_id       = data.aws_identitystore_user.brandon.user_id
  principal_type     = "USER"
  target_id          = "688567306703" # dev account
  target_type        = "AWS_ACCOUNT"
}

# Assign Brandon to ApplicationDeployer in Staging Account
resource "aws_ssoadmin_account_assignment" "brandon_app_staging" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.application_deployer.arn
  principal_id       = data.aws_identitystore_user.brandon.user_id
  principal_type     = "USER"
  target_id          = "400205986141" # staging account
  target_type        = "AWS_ACCOUNT"
}

# Assign Brandon to ApplicationDeployer in Prod Account
resource "aws_ssoadmin_account_assignment" "brandon_app_prod" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.application_deployer.arn
  principal_id       = data.aws_identitystore_user.brandon.user_id
  principal_type     = "USER"
  target_id          = "825765407025" # prod account
  target_type        = "AWS_ACCOUNT"
}

# ReadOnlyAuditor Permission Set
resource "aws_ssoadmin_permission_set" "readonly_auditor" {
  name             = "ReadOnlyAuditor"
  description      = "Read-only access for monitoring and compliance"
  instance_arn     = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  session_duration = "PT12H" # 12 hours
}

# Attach AWS managed policy to ReadOnlyAuditor
resource "aws_ssoadmin_managed_policy_attachment" "readonly_auditor_policy" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.readonly_auditor.arn
}

# Assign Brandon to ReadOnlyAuditor in all accounts
resource "aws_ssoadmin_account_assignment" "brandon_readonly_mgmt" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly_auditor.arn
  principal_id       = data.aws_identitystore_user.brandon.user_id
  principal_type     = "USER"
  target_id          = "396913723725" # management account
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "brandon_readonly_dev" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly_auditor.arn
  principal_id       = data.aws_identitystore_user.brandon.user_id
  principal_type     = "USER"
  target_id          = "688567306703" # dev account
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "brandon_readonly_staging" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly_auditor.arn
  principal_id       = data.aws_identitystore_user.brandon.user_id
  principal_type     = "USER"
  target_id          = "400205986141" # staging account
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "brandon_readonly_prod" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly_auditor.arn
  principal_id       = data.aws_identitystore_user.brandon.user_id
  principal_type     = "USER"
  target_id          = "825765407025" # prod account
  target_type        = "AWS_ACCOUNT"
}
