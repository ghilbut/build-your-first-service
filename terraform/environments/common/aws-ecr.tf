resource aws_ecr_repository default {
  name                 = "${var.srv_name}"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    map(
      "Name", "ecr-${var.srv_name}"
    ),
    local.tags
  )
}
