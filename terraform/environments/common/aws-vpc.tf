data aws_vpc default {
  default = true
}


data aws_subnet defaults {
  count = length(local.az_suffixes)

  availability_zone = "${var.aws_region}${local.az_suffixes[count.index]}"
  default_for_az = true
  vpc_id = data.aws_vpc.default.id
}


data aws_subnet default {
  availability_zone = "${var.aws_region}a"
  default_for_az = true
  vpc_id = data.aws_vpc.default.id
}


/***************************************************************
* use when apply '#13 Make development environment to private network'
resource aws_security_group alb_public {
  name        = "${var.srv_name}-alb-public"
  description = "Allow all traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = merge(
    map(
      "Name",  "sg-${var.srv_name}-alb-public",
    ),
    local.tags, 
  )
}



locals {
  private_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}
***************************************************************/


resource aws_security_group alb_private {
  name        = "${var.srv_name}-alb-private"
  description = "Allow all traffic"
  vpc_id      = data.aws_vpc.default.id

/*
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.private_cidrs
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.private_cidrs
  }
*/

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = merge(
    map(
      "Name",  "sg-${var.srv_name}-alb-private",
    ),
    local.tags, 
  )
}


resource aws_security_group private {
  name        = "${var.srv_name}-private"
  description = "Allow all traffic"
  vpc_id      = data.aws_vpc.default.id

/*
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = local.private_cidrs
  }
*/

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = merge(
    map(
      "Name",  "sg-${var.srv_name}-private",
    ),
    local.tags, 
  )
}
