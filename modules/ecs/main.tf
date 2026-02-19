resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name              = "/ecs-task/athlon-alpha"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "ecs_cluster_logs" {
  name              = "/ecs-cluster/athlon-alpha"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "cluster" {
  name = "athlon-alpha-be-${var.environment}-cluster"
  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_cluster_logs.name
      }
    }
  }
}

data "aws_ami" "ec2_ecs_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-2023.0.20240820-kernel-6.1-x86_64"]
  }

  owners = ["amazon"]
}

data "aws_iam_policy_document" "ecs_ec2_instance_policy" {
  statement {
    sid    = "ECSECRLOGSAccess"
    effect = "Allow"
    actions = [
      "ec2:DescribeTags",
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:UpdateContainerInstancesState",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECSTagResource"
    effect = "Allow"
    actions = [
      "ecs:TagResource"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ecs:CreateAction"
      values = [
        "CreateCluster",
        "RegisterContainerInstance"
      ]
    }
  }

  statement {
    sid    = "AllowECSListTags"
    effect = "Allow"
    actions = [
      "ecs:ListTagsForResource"
    ]
    resources = [
      "arn:aws:ecs:*:*:task/*/*",
    "arn:aws:ecs:*:*:container-instance/*/*"]
  }
}

module "ecs_ec2_instance_role" {
  source                       = "../iam-role"
  service_name                 = "ec2"
  role_name                    = "ecs-ec2-instance-role"
  iam_service_role_policy_json = data.aws_iam_policy_document.ecs_ec2_instance_policy.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = module.ecs_ec2_instance_role.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_ec2_instance_profile" {
  name = "ecs-ec2-instance-profile"
  role = module.ecs_ec2_instance_role.iam_role_name
}

resource "aws_launch_template" "ecs_ec2_launch_template" {
  name_prefix   = "ecs-template-"
  image_id      = data.aws_ami.ec2_ecs_ami.image_id
  instance_type = "t3.small"

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_ec2_instance_profile.name
  }

  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(<<EOF
#!/bin/bash
echo "Done 1"
mkdir -p /etc/ecs
echo "Done 2"
echo "ECS_CLUSTER=${aws_ecs_cluster.cluster.name}" | sudo tee /etc/ecs/ecs.config
echo "Done 3"
sudo systemctl enable ecs
echo "Done 4"
EOF
  )
}

resource "aws_autoscaling_group" "ec2_autscaling_group" {
  name             = "ecs-ec2-instance-autoscaling-group"
  desired_capacity = 1
  max_size         = 1
  min_size         = 1

  launch_template {
    id      = aws_launch_template.ecs_ec2_launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.subnet_ids
}

resource "aws_ecs_capacity_provider" "ec2_capacity" {
  name = "athlon-alpha-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ec2_autscaling_group.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 80
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "capacity_providers" {
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ec2_capacity.name]

  default_capacity_provider_strategy {
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ec2_capacity.name
  }
}

data "aws_iam_policy_document" "ecs_task_execution_policy_document" {
  statement {
    sid = "ECRAccess"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }
  statement {
    sid = "CloudWatchLogsAccess"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

module "ecs_task_execution_role" {
  source                       = "../iam-role"
  role_name                    = "ecs-task-execution-role"
  service_name                 = "ecs-tasks"
  iam_service_role_policy_json = data.aws_iam_policy_document.ecs_task_execution_policy_document.json
}


resource "aws_ecs_task_definition" "task_definition" {
  family                   = "athlon-alpha"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn

  container_definitions = jsonencode([
    {
      name  = "api"
      image = "${var.ecr_repository_url}:latest"


      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_task_logs.name
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "ecs"
        }
      }

      environment = [
        {
          name  = "ASPNETCORE_ENVIRONMENT",
          value = local.deployment_environment
        },
        {
          name  = "ASPNETCORE_URLS"
          value = "http://+:5000"
        },
        {
          name  = "ConnectionStrings__DatabaseConnection"
          value = "Host=${var.rds_hostname};Port=${var.db_port};Database=${var.db_name};Username=${var.db_user};Password=${var.db_password};"
        },
        {
          name  = "ConnectionStrings__RedisConnection"
          value = "${var.redis_endpoint}:${var.redis_port}"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "athlon-alpha-api-${var.environment}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.security_group_ids
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "api"
    container_port   = 5000
  }
}