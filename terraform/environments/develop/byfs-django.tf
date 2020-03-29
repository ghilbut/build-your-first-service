################################################################
##
##  AWS CloudWatch
##

resource aws_cloudwatch_log_group django {
  name              = "${local.srv_name}-${local.stage}-django"
  retention_in_days = 1

  tags = merge(
    map(
      "Name", "${local.srv_name}-${local.stage}-django",
    ),
    local.tags
  )
}



################################################################
##
##  AWS IAM
##

data aws_iam_policy_document assume_role_policy {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


resource aws_iam_role ecsTaskExecutionRole {
  name               = "iam-role-byfs-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


resource aws_iam_role_policy_attachment ecsTaskExecutionRole_policy {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# https://aws.amazon.com/ko/premiumsupport/knowledge-center/ecs-data-security-container-task/
resource aws_iam_policy secret_access_policy {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:ssm:ap-northeast-2:*:parameter/*",
        "arn:aws:secretsmanager:ap-northeast-2:*:secret:*"
      ]
    }
  ]
}
EOF
}

resource aws_iam_role_policy_attachment secrets {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.secret_access_policy.arn
}



################################################################
##
##  AWS Route53
##

resource aws_route53_record django {
  zone_id = data.aws_route53_zone.private.zone_id
  name    = "${local.srv_name}-${local.stage}.${local.domain_name}"
  type    = "A"

  alias {
    name    = data.aws_lb.alb_private.dns_name
    zone_id = data.aws_lb.alb_private.zone_id
    evaluate_target_health = true
  }
}



################################################################
##
##  AWS ECS Fargate
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
    "awslogs-region":          "${var.aws_region}",
    "awslogs-group":           "${aws_cloudwatch_log_group.django.name}",
    "awslogs-stream-prefix":   "${local.srv_name}",
    "awslogs-datetime-format": "\\[%Y-%m-%d %H:%M:%S\\]"
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
##  module:django
##  * application load balancer
##  * auto scaling
##  * ecs service
##  * route53

module django {
  source = "../../modules/aws-ecs-service"

  prefix              = "${local.srv_name}-${local.stage}-django"

  vpc_id              = data.aws_vpc.default.id
  subnet_ids          = [data.aws_subnet.default.id]
  security_group_ids  = [data.aws_security_group.private.id]

  alb_name            = "alb-${local.srv_name}-private"
  alb_listener_arn    = data.aws_lb_listener.http_private.arn
  alb_route_host      = aws_route53_record.django.name
  alb_route_priority  = 100

  cluster_name        = data.aws_ecs_cluster.private.cluster_name
  task_definition_arn = aws_ecs_task_definition.django.arn
  container_name      = "django"
  container_port      = 8000
}
