terraform {
    required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"  # Adjust the version as needed
    }
  }
  backend "s3" {
    bucket       = "my-terraform-state-bucket-unique"  # Update to a unique bucket name
    encrypt      = true
    key          = "terraform/DEV/terraform.tfstate"
    kms_key_id   = "value"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_codestarconnections_connection" "connection" {
  name = var.github_connection_name
}

locals {
    fc_account = "535002858604" # EQRS-FC OIT Dev Account
}

##############################
# IAM Role for CodeBuild
##############################

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-gha-runner-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = "sts:AssumeRole",
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}