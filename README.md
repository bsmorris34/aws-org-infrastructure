# AWS Organization Management

This project manages the AWS Organizations structure, OUs, Service Control Policies, and SSO configuration using Terraform.

## Prerequisites - Management Account Setup

Before running Terraform, the following must be configured manually in the **Management Account**:

### 1. Terraform Backend Resources
- **S3 Bucket**: For Terraform state storage
  - Versioning enabled
  - Server-side encryption enabled
  - Public access blocked
- **DynamoDB Table**: For Terraform state locking
  - Primary key: `LockID` (String)

### 2. Bootstrap IAM Access
- **OrganizationAdmin Permission Set**: Manual creation in AWS SSO
  - Full AWS Organizations permissions
  - IAM permissions for managing SSO
  - **DynamoDB permissions** for Terraform state locking
  - **S3 permissions** for Terraform state storage
  - Used as bootstrap role to run Terraform
  - Assign to yourself for initial setup

### 3. Manual Account Creation
- **bramco-security account**: Create manually before running Terraform
  - Terraform will move it to Security OU after creation

### 4. AWS SSO/Identity Center
- **Enable AWS SSO** in the management account (if not already enabled)
- **Configure identity source** (AWS SSO directory or external IdP)

### 5. GitHub Actions OIDC Setup (for CI/CD)
- **OIDC Provider**: Create GitHub Actions OIDC provider
  ```bash
  aws iam create-open-id-connect-provider \
    --url https://token.actions.githubusercontent.com \
    --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
    --client-id-list sts.amazonaws.com \
    --profile management-org
  ```
- **GitHubActionsRole**: Create IAM role for CI/CD pipeline
  ```bash
  # Create trust policy (replace with your GitHub repo)
  cat > github-actions-trust-policy.json << 'EOF'
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub": "repo:USERNAME/REPO_NAME:ref:refs/heads/main"
          }
        }
      }
    ]
  }
  EOF
  
  # Create role
  aws iam create-role \
    --role-name GitHubActionsRole \
    --assume-role-policy-document file://github-actions-trust-policy.json \
    --profile management-org
  
  # Attach policies
  aws iam attach-role-policy \
    --role-name GitHubActionsRole \
    --policy-arn arn:aws:iam::aws:policy/AWSOrganizationsFullAccess \
    --profile management-org
  
  aws iam attach-role-policy \
    --role-name GitHubActionsRole \
    --policy-arn arn:aws:iam::aws:policy/AWSBudgetsActionsWithAWSResourceControlAccess \
    --profile management-org
  
  aws iam attach-role-policy \
    --role-name GitHubActionsRole \
    --policy-arn arn:aws:iam::aws:policy/IAMFullAccess \
    --profile management-org
  ```
- **GitHub Secret**: Add `AWS_ROLE_ARN` secret with role ARN value

## What Terraform Will Manage

- **Organizational Units**: Security OU, Workloads OU, Bramco OU
- **Account Organization**: Move accounts to appropriate OUs
- **Service Control Policies**: Root user prevention, region restrictions, production controls
- **SSO Permission Sets**: InfrastructureAdmin, ApplicationDeployer, ReadOnlyAuditor
- **Permission Set Assignments**: User/group assignments to accounts
- **MFA Enforcement**: Require MFA for all SSO users

## Deployment Order

1. Complete all prerequisites above
2. Configure Terraform backend
3. Run `terraform init`
4. Run `terraform plan`
5. Run `terraform apply`

## Architecture

This follows the multi-account strategy defined in the project documentation with manual account creation and IaC-managed organizational structure.

## Important Notes

### Terraform Destroy Behavior
If you run `terraform destroy`, it will remove all IaC-managed resources:
- Organizational Units (OUs)
- Service Control Policies (SCPs)
- SSO Permission Sets and assignments

**Manual steps required after destroy/apply:**
- Accounts will return to Root organization level
- You must manually move accounts back to appropriate OUs:
  - bramco-dev, bramco-staging, bramco-prod → Workloads OU
  - bramco-security (when created) → Security OU

**What remains after destroy:**
- AWS accounts (manually created)
- OrganizationAdmin permission set (bootstrap role)
- S3 bucket and DynamoDB table (Terraform backend)
- AWS Organization itself