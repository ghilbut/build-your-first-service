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

resource aws_ecs_task_definition django {
  family                   = "ecs-${local.srv_name}-${local.stage}-django"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  # defined in role.tf
  #task_role_arn = aws_iam_role.app_role.arn

  container_definitions    = <<EOF
[
  {
    "name": "django",
    "image": "ghilbut/byfs:latest",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 8000
      }
    ],
    "entryPoint": [
      "./manage.py",
      "runserver",
      "0:8000"
    ],
    "environment": [
      {
        "name": "BYFS_${upper(local.stage)}_DB_NAME",
        "value": "${local.stage}"
      },
      {
        "name": "BYFS_${upper(local.stage)}_DB_HOST",
        "value": "${aws_route53_record.mysql.name}"
      },
      {
        "name": "BYFS_${upper(local.stage)}_DB_PORT",
        "value": "3306"
      },
      {
        "name": "BYFS_${upper(local.stage)}_DB_USER",
        "value": "${var.mysql_username}"
      },
      {
        "name": "BYFS_${upper(local.stage)}_DB_PASSWORD",
        "value": "${var.mysql_password}"
      },
      {
        "name": "DJANGO_SETTINGS_MODULE",
        "value": "byfs.settings.${local.stage}"
      }
    ]
  }
]
EOF

  tags = merge(
    map(
      "Name", "ecs-${local.srv_name}-${local.stage}-django-task-definition"
    ),
    local.tags
  )
}


resource aws_ecs_service django {
  depends_on = [
    aws_lb_listener.django,
  ]

  lifecycle {
    ignore_changes = [
      task_definition,
    ]
  }

  name            = "${local.srv_name}-${local.stage}-django"
  cluster         = aws_ecs_cluster.default.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.django.arn
  desired_count   = 1

  network_configuration {
    subnets          = [data.aws_subnet.default.id]
    security_groups  = [data.aws_security_group.private.id]

    # if you has NAT, set to false
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
