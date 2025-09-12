# AWS Organizations setup with Security and Workloads OUs

# Data source to reference existing organization
data "aws_organizations_organization" "main" {}

# Security OU for centralized logging and monitoring
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = data.aws_organizations_organization.main.roots[0].id
}

# Workloads OU for application accounts
resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = data.aws_organizations_organization.main.roots[0].id
}