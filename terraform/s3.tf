
##############################
# S3 Bucket for Runner Artifacts
##############################

resource "aws_s3_bucket" "artifacts_bucket" {
  bucket        = "codebuild-gha-runner-artifacts-bucket"  # Update to a unique bucket name
  force_destroy = true

  tags = {
    Name = "CodeBuild GHA Runner Artifacts Bucket"
  }
}

##############################
# S3 Bucket for CodeBuild Logs
##############################

resource "aws_s3_bucket" "logs_bucket" {
  bucket        = "codebuild-gha-runner-logs-bucket"  # Update to a unique bucket name
  force_destroy = true

  tags = {
    Name = "CodeBuild GHA Runner Logs Bucket"
  }
}