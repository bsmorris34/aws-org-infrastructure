# Restrict root user access in member accounts
# Create the service control policy (SCP) to restrict root user access to member accounts
resource "aws_organizations_policy" "prevent_root_user" {
  name        = "PreventRootUserAccess"
  description = "Prevent root user access in member accounts"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:userid" = "*:root"
          }
        }
      }
    ]
  })
}

# Attach to Security OU
resource "aws_organizations_policy_attachment" "prevent_root_security" {
  policy_id = aws_organizations_policy.prevent_root_user.id
  target_id = aws_organizations_organizational_unit.security.id
}

# Attach to Workloads OU  
resource "aws_organizations_policy_attachment" "prevent_root_workloads" {
  policy_id = aws_organizations_policy.prevent_root_user.id
  target_id = aws_organizations_organizational_unit.workloads.id
}

# Region Restriction SCP
resource "aws_organizations_policy" "restrict_regions" {
  name        = "RestrictRegions"
  description = "Restrict access to us-east-1 and us-west-2 only"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "us-east-1",
              "us-west-2"
            ]
          }
        }
      }
    ]
  })
}

# Attach to Security OU
resource "aws_organizations_policy_attachment" "restrict_regions_security" {
  policy_id = aws_organizations_policy.restrict_regions.id
  target_id = aws_organizations_organizational_unit.security.id
}

# Attach to Workloads OU
resource "aws_organizations_policy_attachment" "restrict_regions_workloads" {
  policy_id = aws_organizations_policy.restrict_regions.id
  target_id = aws_organizations_organizational_unit.workloads.id
}

# Production Controls SCP
resource "aws_organizations_policy" "production_controls" {
  name        = "ProductionControls"
  description = "Restrict high-risk actions in production environment"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyDatabaseDeletion"
        Effect = "Deny"
        Action = [
          "rds:DeleteDBInstance",
          "rds:DeleteDBCluster",
          "dynamodb:DeleteTable"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyLargeInstances"
        Effect = "Deny"
        Action = [
          "ec2:RunInstances"
        ]
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          StringEquals = {
            "ec2:InstanceType" = [
              "m5.8xlarge",
              "m5.12xlarge",
              "m5.16xlarge",
              "m5.24xlarge"
            ]
          }
        }
      },
      {
        Sid    = "RequireMFAForSensitiveActions"
        Effect = "Deny"
        Action = [
          "iam:DeleteRole",
          "iam:DeletePolicy",
          "s3:DeleteBucket"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

# Attach only to production account (not the entire OU)
resource "aws_organizations_policy_attachment" "production_controls" {
  policy_id = aws_organizations_policy.production_controls.id
  target_id = "825765407025" # bramco-prod account ID
}

