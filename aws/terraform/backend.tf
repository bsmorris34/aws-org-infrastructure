terraform {
  backend "s3" {
    bucket         = "bramco-terraform-state-3725"
    key            = "aws-organization/terraform.tfstate"
    region         = "us-east-1" # Replace with your bucket's region
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
