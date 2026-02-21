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
    sid = "EC2InstanceAccess"
    effect = "Allow"
    actions = [
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DescribeDhcpOptions"
    ]
    resources = ["*"]
  }

  statement {
    sid = "CodeBuildReporting"
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases"
    ]
    resources = ["*"]
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

  statement {
    sid    = "ECRAccess"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = ["*"]
  }
}

module "code_build_iam_role" {
  source                       = "../iam-role"
  service_name                 = "codebuild"
  role_name                    = "${var.build_name}-codebuild-role"
  iam_service_role_policy_json = data.aws_iam_policy_document.codebuild_permissions_policy_document.json
}

resource "aws_codebuild_project" "codebuild_project" {
  name         = var.build_name
  service_role = module.code_build_iam_role.iam_role_arn

  source {
    type = "CODEPIPELINE"
    buildspec = var.buildspec_file_name
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  vpc_config {
    vpc_id = var.vpc_id
    subnets = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
}