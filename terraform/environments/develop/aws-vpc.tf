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
