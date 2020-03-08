data aws_lb alb_private {
  name = "alb-${local.srv_name}-private"
}


resource aws_lb_target_group django {
  name        = "alb-${local.srv_name}-${local.stage}-django"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  #health_check {
  #  enabled = false
  #}
}


resource aws_lb_listener django {
  load_balancer_arn = data.aws_lb.alb_private.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.django.arn
  }
}


resource aws_lb_listener_rule django {
  listener_arn = aws_lb_listener.django.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.django.arn
  }

  condition {
    host_header {
      values = [
        aws_route53_record.django.name,
      ]
    }
  }
}
