// modules/pipeline/main.tf
// Fix resource name conflicts by adding uniqueness suffixes and update CodeBuild compute type.
// Also, ensure the RDS password variable is validated outside this to use allowed characters.

resource "random_id" "unique_suffix" {
  byte_length = 4
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role-${random_id.unique_suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "codepipeline_policy" {
  name        = "codepipeline-policy-${random_id.unique_suffix.hex}"
  description = "Allow CodePipeline to invoke CodeBuild and access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "s3:*",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

resource "aws_codebuild_project" "app_build" {
  name          = "app-build-project-${random_id.unique_suffix.hex}"
  description   = "Build project for app"

  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.github_owner}/${var.github_repo}.git"
    git_clone_depth = 1
    buildspec       = <<EOF
version: 0.2

phases:
  install:
    runtime-versions:
      python: 3.10
    commands:
      - echo Installing...
  build:
    commands:
      - echo Build started on `date`
  post_build:
    commands:
      - echo Build completed on `date`
EOF
  }

  tags = var.tags
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-service-role-${random_id.unique_suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "codebuild-policy-${random_id.unique_suffix.hex}"

  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "s3:*",
          "ec2:Describe*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = var.pipeline_role_arn
  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn     = "arn:aws:codeconnections:us-east-1:396608811086:connection/6d57289b-f498-49d9-8bd3-e65867258531"
        FullRepositoryId  = "your-github-username/your-repo-name"
        BranchName        = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "AppBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  # Optional Deploy stage
  # stage {
  #   name = "Deploy"
  #   ...
  # }
}
