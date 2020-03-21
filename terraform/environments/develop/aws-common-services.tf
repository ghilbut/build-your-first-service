################################################################
##
##  ECS Fargate
##

data aws_ecs_cluster private {
  cluster_name = "${local.srv_name}-develop"
}



################################################################
##
##  Load Balancer
##

data aws_lb alb_private {
  name = "alb-${local.srv_name}-private"
}

data aws_lb_listener http_private {
  load_balancer_arn = data.aws_lb.alb_private.arn
  port              = 80
}



################################################################
##
##  Route 53
##

data aws_route53_zone public {
  name         = local.domain_name
  private_zone = false
}

data aws_route53_zone private {
  name         = local.domain_name
  #private_zone = true
  private_zone = false
}



################################################################
##
##  VPC
##

data aws_vpc default {
  default = true
}


data aws_subnet default {
  availability_zone = "${var.aws_region}a"
  default_for_az = true
}


data aws_security_group private {
  name   = "${local.srv_name}-private"
  vpc_id = data.aws_vpc.default.id
}
