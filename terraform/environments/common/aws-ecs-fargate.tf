resource aws_ecs_cluster develop {
  name               = "${var.srv_name}-develop"
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT",
  ]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    map(
      "Name", "ecs-${var.srv_name}-develop"
    ),
    local.tags
  )
}


/*
resource aws_ecs_cluster release {
  name               = "${var.srv_name}-release"
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT",
  ]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    map(
      "Name", "ecs-${var.srv_name}-release"
    ),
    local.tags
  )
}
*/
