import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as codebuild from 'aws-cdk-lib/aws-codebuild';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as codestarconnections from 'aws-cdk-lib/aws-codestarconnections';

export class CodeBuildRunnerStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create an S3 bucket to store artifacts.
    // The bucket is configured so that the artifacts are namespaced by the build ID.
    const artifactBucket = new s3.Bucket(this, 'ArtifactsBucket', {
      removalPolicy: cdk.RemovalPolicy.DESTROY, // NOT recommended for production
      autoDeleteObjects: true, // allows bucket deletion even if objects exist
    });

    // Create a CodeStar Connections connection for GitHub.
    // (This creates the resource but you may need to follow-up in the console to complete the connection.)
    const githubConnection = new codestarconnections.CfnConnection(this, 'GithubConnection', {
      connectionName: 'github-connection',
      providerType: 'GitHub', // using the GitHub App connection method
    });

    // Create the CodeBuild project.
    // The project is defined to use the CodeStar connection as its source,
    // the managed Amazon Linux 2 Node.js image for the build environment,
    // and artifacts are stored in the S3 bucket.
    const runnerProject = new codebuild.Project(this, 'GitHubActionsRunnerProject', {
      projectName: 'GitHubActionsRunnerProject',
      description: 'CodeBuild project for hosting GitHub Actions runners',
      // Use a CodeStar connection as the source
      source: codebuild.Source.codeStarConnection(
        'https://github.com/tdonaworth/GHA-Runner-Test-Repo.git',
        {
          connectionArn: githubConnection.attrConnectionArn,
          // A minimal buildspec (the actual runner logic will be provided by the runner image)
          buildSpec: codebuild.BuildSpec.fromObject({
            version: '0.2',
            phases: {
              build: {
                commands: [
                  'echo "Running GitHub Actions runner..."'
                ]
              }
            },
            artifacts: {
              'files': ['**/*'],
            }
          }),
        }
      ),
      // Artifacts configuration: store artifacts in S3 with a BUILD_ID namespace.
      artifacts: codebuild.Artifacts.s3({
        bucket: artifactBucket,
        namespaceType: codebuild.ArtifactsNamespaceType.BUILD_ID,
        packaging: codebuild.ArtifactsPackaging.ZIP,
      }),
      // Environment configuration: use a managed image
      // In this example, we choose the latest Amazon Linux 2 Node.js image.
      environment: {
        buildImage: codebuild.LinuxBuildImage.AMAZON_LINUX_2_NODE_20,
        type: codebuild.BuildEnvironmentType.LINUX_LAMBDA_CONTAINER,
        computeType: codebuild.ComputeType.BUILD_LAMBDA_XGB,
      },
    });

    // IMPORTANT: For GitHub Actions runners hosted on CodeBuild, the project must be of type "RUNNER".
    // The high-level CDK construct doesn't (yet) expose this property, so we override it on the low-level CfnProject.
    const cfnProject = runnerProject.node.defaultChild as codebuild.CfnProject;
    cfnProject.projectType = 'RUNNER';
  }
}
