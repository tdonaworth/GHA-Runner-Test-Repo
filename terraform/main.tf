terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"  # Adjust the version as needed
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

##############################
# IAM Role for CodeBuild
##############################

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-example-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

##############################
# CodeStar Connections Connection
##############################

resource "aws_codestarconnections_connection" "example" {
  name          = "example-connection"
  provider_type = "GitHub"   # For GitHub. For Bitbucket or others, adjust accordingly.
  # This requires going into the Console and completing the connection.
}

##############################
# CodeBuild Project
##############################

resource "aws_codebuild_project" "example" {
  name          = "example-codebuild-project"
  description   = "Example project using CodeStar Connection for source"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 60

  # Define the artifacts; in this example, no artifacts are produced.
  artifacts {
    type = "NO_ARTIFACTS"
  }

  # Define the build environment.
  environment {
    compute_type                = "BUILD_LAMBDA_XGB1_5"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_LAMBDA_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "EXAMPLE_VAR"
      value = "example_value"
    }
  }

  # Define the source using the CodeStar connection.
  source {
    type      = "CODESTAR"  # Use CODESTAR to reference a CodeStar connection.
    buildspec = "buildspec.yml"  # The buildspec file in your repo

    # The location value here must be the ARN of your CodeStar connection.
    # CodeBuild will use this connection to fetch your source.
    location = aws_codestarconnections_connection.example.arn
  }
}

##############################
# (Optional) Output the Connection ARN
##############################

output "codestar_connection_arn" {
  description = "ARN of the CodeStar Connections connection"
  value       = aws_codestarconnections_connection.example.arn
}
