################################################################
##
##  common
##

##--------------------------------------------------------------
##  cluster

resource aws_ecs_cluster default {
  name               = "${local.srv_name}"
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT",
  ]

  setting {
    name  = "containerInsights"
    #value = "enabled"
    value = "disabled"
  }

  tags = merge(
    map(
      "Name", "ecs-${local.srv_name}-django"
    ),
    local.tags
  )
}


################################################################
##
##  django
##

##--------------------------------------------------------------
##  local variables

locals {
  family         = "${local.srv_name}-${local.stage}-django"
  cpu            = "256"
  memory         = "512"
  execution_role = aws_iam_role.ecsTaskExecutionRole.arn

  environment = [
    {
      "name": "DJANGO_SETTINGS_MODULE",
      "value": "byfs.settings.${local.stage}"
    }
  ]

  secrets = [
    {
      "name": "BYFS_${upper(local.stage)}_DB_HOST",
      "valueFrom": aws_secretsmanager_secret.mysql_host.arn
    },
    {
      "name": "BYFS_${upper(local.stage)}_DB_PORT",
      "valueFrom": aws_secretsmanager_secret.mysql_port.arn
    },
    {
      "name": "BYFS_${upper(local.stage)}_DB_NAME",
      "valueFrom": aws_secretsmanager_secret.mysql_name.arn
    },
    {
      "name": "BYFS_${upper(local.stage)}_DB_USER",
      "valueFrom": aws_secretsmanager_secret.mysql_username.arn
    },
    {
      "name": "BYFS_${upper(local.stage)}_DB_PASSWORD",
      "valueFrom": aws_secretsmanager_secret.mysql_password.arn
    }
  ]
}


##--------------------------------------------------------------
##  templates

data template_file django_containers {
  template = file("${path.module}/../../templates/ecs/django-container-definitions.json")

  vars = {
    name        = "django"
    image       = "${data.terraform_remote_state.common.outputs.ecr_django_url}:latest"
    environment = jsonencode(local.environment)
    secrets     = jsonencode(local.secrets)
    log_config  =<<EOF
{
  "logDriver": "awslogs",
  "options": {
    "awslogs-region": "${var.aws_region}",
    "awslogs-group": "${local.srv_name}-${local.stage}-django",
    "awslogs-stream-prefix": "${local.srv_name}",
    "awslogs-datetime-format": "[%d/%b/%Y %H:%M:%S]"
  }
}
EOF
  }
}


data template_file django_task {
  template = file("${path.module}/../../templates/ecs/django-task-definition.json")

  vars = {
    family         = local.family
    execution_role = local.execution_role
    containers     = data.template_file.django_containers.rendered
    tags           = jsonencode([for name, value in merge(
        map(
          "Name", "ecs-${local.srv_name}-${local.stage}-django-task-definition"
        ),
        local.tags
      ): {
        key = name
        value = value
      }
    ])
  }
}

resource local_file task_definition {
  sensitive_content = data.template_file.django_task.rendered
  filename = "${path.module}/../../../django/ecs/${local.stage}/django-task-definition.json"
}


##--------------------------------------------------------------
##  task definition

resource aws_ecs_task_definition django {
  family                   = local.family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.cpu
  memory                   = local.memory
  execution_role_arn       = local.execution_role

  # defined in role.tf
  #task_role_arn = aws_iam_role.app_role.arn

  container_definitions    = data.template_file.django_containers.rendered

  tags = merge(
    map(
      "Name", "ecs-${local.srv_name}-${local.stage}-django-task-definition"
    ),
    local.tags
  )
}


##--------------------------------------------------------------
##  service

resource aws_ecs_service django {
  depends_on = [
    aws_lb_listener.django,
  ]

  lifecycle {
    ignore_changes = [
      task_definition,
    ]
  }

  name                               = "${local.srv_name}-${local.stage}-django"
  cluster                            = aws_ecs_cluster.default.id
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  launch_type                        = "FARGATE"
  task_definition                    = aws_ecs_task_definition.django.arn
  desired_count                      = 1

  network_configuration {
    subnets          = [data.aws_subnet.default.id]
    security_groups  = [data.aws_security_group.private.id]

    # if you have NAT, set to false
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.django.id
    container_name   = "django"
    container_port   = 8000
  }

  deployment_controller {
    type = "ECS"
  }
}
