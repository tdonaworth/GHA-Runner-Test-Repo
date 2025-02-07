#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { CodeBuildRunnerStack } from '../lib/codebuild-runner-stack';

const app = new cdk.App();
new CodeBuildRunnerStack(app, 'CodeBuildRunnerStack', {
  /* If you want to specify an environment, add:
  env: { account: '123456789012', region: 'us-east-1' }
  */
});
app.synth();
