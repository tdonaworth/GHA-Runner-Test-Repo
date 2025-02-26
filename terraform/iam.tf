resource "aws_iam_role" "codebuild-gha-runner-deploy-role" {
  name                 = "${aws_codebuild_project.gha-runners.name}-deploy-role"
  path                 = "/service-role/"
  permissions_boundary = "arn:aws:iam::${local.fc_account}:policy/cms-cloud-admin/developer-boundary-policy"
    assume_role_policy   = jsonencode({
        Version   = "2012-10-17",
        Statement = [
        {
            Effect    = "Allow",
            Principal = {
            Service = "codebuild.amazonaws.com"
            },
            Action    = "sts:AssumeRole"
        }
        ]
    })
}

resource "aws_iam_role_policy" "CodeBuildBasePolicy" {
  name   = "CodeBuildBasePolicy"
  role   = aws_iam_role.deploy_role.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:us-east-1:${locals.fc_account}:log-group:/aws/codebuild/${aws_codebuild_project.gha-runners.name}",
                "arn:aws:logs:us-east-1:${locals.fc_account}:log-group:/aws/codebuild/${aws_codebuild_project.gha-runners.name}:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-us-east-1-*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codebuild-gha-runner-artifacts-bucket",
                "arn:aws:s3:::codebuild-gha-runner-artifacts-bucket/*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "arn:aws:codebuild:us-east-1:${locals.fc_account}:report-group/${aws_codebuild_project.gha-runners.name}-*"
            ]
        }
    ]
})
}