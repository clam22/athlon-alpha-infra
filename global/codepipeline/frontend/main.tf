module "aws_codestar_connection" {
  source        = "../../../modules/code-star-connection"
  name          = var.codestar_connection_name
  provider_type = var.codestar_connection_provider_type
}

module "s3_artifact_bucket" {
  source      = "../../../modules/s3"
  bucket_name = var.artifact_bucket_name
}

module "code_build_project" {
  source              = "../../../modules/code-build"
  build_name          = "athlon-alpha-frontend-build"
  artifact_bucket_arn = module.s3_artifact_bucket.bucket_arn
}

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
    ]
    resources = [
      module.code_build_project.code_build_project_arn
    ]
  }

  statement {
    sid    = "IAMPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      module.code_build_project.code_build_project_arn
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    sid    = "UseCodeStarConnection"
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = [
      module.aws_codestar_connection.codestar_connection_arn
    ]
  }

  statement {
    sid    = "S3DeploymentAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::athlon-alpha-website-dev",
      "arn:aws:s3:::athlon-alpha-website-dev/*"
    ]
  }
}

module "codepipeline_iam_role" {
  source                       = "../../../modules/iam-role"
  service_name                 = "codepipeline"
  iam_service_role_policy_json = data.aws_iam_policy_document.codepipeline_policy.json
}

resource "aws_codepipeline" "frontend_pipeline" {
  depends_on = [
    module.aws_codestar_connection,
    module.codepipeline_iam_role,
    module.s3_artifact_bucket,
    module.code_build_project
  ]

  name     = "frontend-pipeline"
  role_arn = module.codepipeline_iam_role.iam_role_arn

  artifact_store {
    location = module.s3_artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = module.aws_codestar_connection.codestar_connection_arn
        FullRepositoryId = "clam22/athlon-alpha-fe"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build_React"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = module.code_build_project.code_build_project_name
      }
    }
  }

  stage {
    name = "DeployDev"

    action {
      name            = "DeployDev"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        BucketName = "${var.website_bucket_name}-dev"
        Extract    = "true"
      }
    }
  }

}



