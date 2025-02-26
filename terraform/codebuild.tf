resource "aws_codebuild_project" "gha-runners" {
  name          = "CodeBuild-GHA-Runners"
  description   = "CodeBuild project for GitHub Actions runners"
  service_role  = aws_iam_role.codebuild-gha-runner-deploy-role.arn
  build_timeout = 15

  # Artifacts configuration:
  # Runner artifacts will be stored in the specified S3 bucket, namespaced by BUILD_ID.
  artifacts {
    type           = "S3"
    location       = aws_s3_bucket.artifacts_bucket.bucket
    packaging      = "ZIP"
    namespace_type = "BUILD_ID"
  }

  # Logs configuration:
  # CodeBuild logs are sent to the specified S3 bucket.
  logs_config {
    cloudwatch_logs {
      status = "DISABLED"
    }
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.logs_bucket.bucket}/logs"
    }
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
    location = "aws_codestarconnections_connection.github_connection.arn"
  }
}