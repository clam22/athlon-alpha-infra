module "codeconnection" {
  source        = "../../../modules/code-connection"
  name          = "github-backend-connection"
  provider_type = "GitHub"
}
module "s3_artifact_bucket" {
  source                     = "../../../modules/s3"
  bucket_name                = "athlon-alpha-backend-pipeline-artifacts"
  allow_public_bucket_access = true
}

module "code_migrations_project" {
  source = "../../../modules/code-build"
  build_name = "athlon-alpha-backend-migrations"
  artifact_bucket_arn = module.s3_artifact_bucket.bucket_arn
  buildspec_file_name = "migrationsspec.yml"
  vpc_id = data.terraform_remote_state.dev_env_state_file.outputs.vpc_id
  security_group_ids = data.terraform_remote_state.dev_env_state_file.outputs.codepipeline_security_group_ids
  subnet_ids = data.terraform_remote_state.dev_env_state_file.outputs.private_app_subnet_ids
  environment_variables = {
    "ConnectionStrings__DatabaseConnection" = "Host=${local.db_hostname};Port=${local.db_port};Database=${local.db_name};Username=${local.db_user};Password=${local.db_password};"
  }
}

module "code_testing_project" {
  source = "../../../modules/code-build"
  build_name = "athlon-alpha-backend-testing"
  artifact_bucket_arn = module.s3_artifact_bucket.bucket_arn
  buildspec_file_name = "testspec.yml"
  vpc_id = data.terraform_remote_state.dev_env_state_file.outputs.vpc_id
  security_group_ids = data.terraform_remote_state.dev_env_state_file.outputs.codepipeline_security_group_ids
  subnet_ids = data.terraform_remote_state.dev_env_state_file.outputs.private_app_subnet_ids
}

module "code_push_ecr_project" {
  source = "../../../modules/code-build"
  build_name = "athlon-alpha-backend-ecr"
  artifact_bucket_arn = module.s3_artifact_bucket.bucket_arn
  buildspec_file_name = "ecrspec.yml"
  vpc_id = data.terraform_remote_state.dev_env_state_file.outputs.vpc_id
  security_group_ids = data.terraform_remote_state.dev_env_state_file.outputs.codepipeline_security_group_ids
  subnet_ids = data.terraform_remote_state.dev_env_state_file.outputs.private_app_subnet_ids
  environment_variables = {
    "REPOSITORY_URI"     = data.terraform_remote_state.registry_state_file.outputs.repository_url
    "AWS_DEFAULT_REGION" = "eu-north-1"
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    sid    = "S3ArtifactsAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetObjectVersion",
      "s3:ListBucket"
    ]
    resources = [
      "${module.s3_artifact_bucket.bucket_arn}",
      "${module.s3_artifact_bucket.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "CodeBuildAccess"
    effect = "Allow"
    actions = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds",
      "codebuild:CreateReportGroup"
    ]
    resources = [
      module.code_push_ecr_project.arn,
      module.code_testing_project.arn,
      module.code_migrations_project.arn
    ]
  }

  statement {
    sid    = "IAMPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      module.code_testing_project.arn,
      module.code_migrations_project.arn,
      module.code_push_ecr_project.arn,
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecs-task-execution-role"
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["codebuild.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    sid    = "UseCodeConnection"
    effect = "Allow"
    actions = [
      "codeconnections:UseConnection",
      "codestar-connections:UseConnection"
    ]
    resources = [
      module.codeconnection.connection_arn
    ]
  }

  statement {
    sid    = "ECSAccess"
    effect = "Allow"
    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:TagResource"
    ]
    resources = ["*"]
  }
}

module "codepipeline_iam_role" {
  source                       = "../../../modules/iam-role"
  service_name                 = "codepipeline"
  role_name                    = "backend-codepipeline-role"
  iam_service_role_policy_json = data.aws_iam_policy_document.codepipeline_policy.json
}


resource "aws_codepipeline" "backend_pipeline" {
  name     = "backend-pipeline"
  role_arn = module.codepipeline_iam_role.iam_role_arn

  artifact_store {
    location = module.s3_artifact_bucket.bucket
    type     = "S3"
  }
  stage {
    name = "Source"

    action {
      name             = "PullFromGithub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = module.codeconnection.connection_arn
        FullRepositoryId = "clam22/athlon-alpha-be"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Testing"

    action {
      name = "RunTests"
      category = "Test"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["source_output"]
      configuration = {
        ProjectName = module.code_testing_project.name
      }
    }
  }

  stage {
    name = "Build"
    action {
      name = "RunMigrations"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["source_output"]
      configuration = {
        ProjectName = module.code_migrations_project.name
      }
    }
    action {
      name             = "PushToECR"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = module.code_push_ecr_project.name
      }
    }
  }

  stage {
    name = "DevEnvDeployment"

    action {
      name            = "DeployToECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = data.terraform_remote_state.dev_env_state_file.outputs.ecs_cluster_name
        ServiceName = data.terraform_remote_state.dev_env_state_file.outputs.ecs_service_name
        FileName    = "imagedefinitions.json"
      }
    }

  }
}

