/***************************************************************
* use when apply '#13 Make development environment to private network'
resource aws_lb alb_public {
  name               = "alb-${var.srv_name}-public"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_public.id]
  subnets            = data.aws_subnet.defaults.*.id

  tags = merge(
    map(
      "Name",  "alb-${var.srv_name}-public",
    ),
    local.tags, 
  )
}
***************************************************************/


resource aws_lb alb_private {
  name               = "alb-${var.srv_name}-private"
  #internal           = true
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_private.id]
  subnets            = data.aws_subnet.defaults.*.id

  tags = merge(
    map(
      "Name",  "alb-${var.srv_name}-private",
    ),
    local.tags, 
  )
}


resource aws_lb_listener http_private {
  load_balancer_arn = aws_lb.alb_private.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Application Load Balancer default response"
      status_code  = "200"
    }
  }
}
