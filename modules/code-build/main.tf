data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "codebuild_permissions_policy_document" {
  statement {
    sid    = "S3ArtifactsAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListObject"
    ]
    resources = [
      "${var.artifact_bucket_arn}",
      "${var.artifact_bucket_arn}/*"
    ]
  }

  statement {
    sid    = "CodePipelineIntegration"
    effect = "Allow"
    actions = [
      "codepipeline:PutJobSuccessResult",
      "codepipeline:PutJobFailureResult"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CloudWatchLogsAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:eu-north-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*"
    ]
  }
}

module "code_build_iam_role" {
  source                       = "../iam-role"
  service_name                 = "codebuild"
  iam_service_role_policy_json = data.aws_iam_policy_document.codebuild_permissions_policy_document.json
}

resource "aws_codebuild_project" "codebuild_project" {
  name         = var.build_name
  service_role = module.code_build_iam_role.iam_role_arn

  source {
    type = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
}