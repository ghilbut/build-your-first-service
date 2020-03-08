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
