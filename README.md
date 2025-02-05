# GHA-Runner-Test-Repo
This Repository is to test out AWS CodeBuild GitHub Action Runners


Resources: 
- [Tutorial: Configure a CodeBuild-hosted GitHub Actions Runner](https://docs.aws.amazon.com/codebuild/latest/userguide/action-runner.html)
- [Label overrides supported with the CodeBuild-hosted GitHub Actions runner](https://docs.aws.amazon.com/codebuild/latest/userguide/sample-github-action-runners-update-labels.html)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)


# Basic Setup (AWS Console)
## 1. CodeConnection
    Create a `CodeConnection` in AWS CodeBuild

## 2. CodeBuild Project

### Project Configuration
1. Project name: Specify a project name
2. Project type: Select `Runner project`
3. Additional configuration: provide any additional configuration as needed:

    a. Description: Provide a description for the project

    b. Public build access access allows you to make the build results, including logs and artifacts, for this project available for the general public.

    c. Build badge - only available on EC2 based runners

    d. Enable concurrent build limit - Limit the number of allowed concurrent builds for this project.

    e. Tags - Add tags to the project

### Source
4. Source: Select the source provider and repository

    a. Source provider: Select `GitHub`

    b. Credential - this may already be setup since you created the CodeConnection in Step 1. If not, select `manage account credentials`. If you need to override these, you can select `Use override credentials` and provide the necessary information.

    c. Repository: Select the repository

    d. Source version: Select the branch

### Primary source webhook events
5. Specify how you want your webhook events to be triggered - I opted to keep defaults

### Environment
6. Specify how you want the Runners setup

    a. Provisioning model: On-demand| Reserved Capacity

    b. Environment image: Managed image | Custom image

    c. Compute: EC2 | AWS Lambda

    I preferred to go with On-demand, Managed image, Lambda; and then simply specify your default OS and runtime that best fits your projects. This is just the default, and you can override this in the Action workflow files.

    d. Service role: Select the service role that you want to use for this project. If you don't have a service role, you can create one.

### Buildspec
7. Buildspec: Select the buildspec file that you want to use for this project. If you don't have a buildspec file, you can create one. 

I left this as default, letting CodeBuild manage this.

### Batch configuration
8. Specify the batch configuration for the project. This is optional.

### Artifacts
9. Specify the artifacts storage that you want for this project. This is optional. 
If you wish to have saved artifacts, like scan results, logs, etc. you can specify the S3 bucket and path to store these.

### Logs
10. Specify the CloudWatch log group that you want to use for this project. This is optional.

# GitHub Actions Configuration
## 1. Create a new workflow file / Edit existing workflow file

The core change that you will need to make to your GitHub Actions workflow file is to specify the `runs-on` key to be `codebuild-<project-name>`. This will tell GitHub Actions to use the AWS CodeBuild Runner that you have setup in the previous steps.

You can also specify the `github.run_id` and `github.run_attempt` to make the runner unique for each run.

```yaml
name: Hello World
on: [push]
jobs:
  Hello-World-Job:
    runs-on:
      - codebuild-tdonaworth-GitHub-Runners-${{ github.run_id }}-${{ github.run_attempt }}
    steps:
      - run: echo "Hello World!"
```

You can also specify specific overrides for the runner via the `runs-on` labels

[Label overrides supported with the CodeBuild-hosted GitHub Actions runner](https://docs.aws.amazon.com/codebuild/latest/userguide/sample-github-action-runners-update-labels.html)

Example:
```yaml
name: Hello World
on: [push]
jobs:
  Hello-World-Job:
    runs-on:
      - codebuild-myProject-${{ github.run_id }}-${{ github.run_attempt }}
      - image:${{ matrix.os }}
      - instance-size:${{ matrix.size }}
      - fleet:myFleet
      - buildspec-override:true
    strategy:
      matrix:
        include:
          - os: arm-3.0
            size: small
          - os: linux-5.0
            size: large
    steps:
      - run: echo "Hello World!"
```

