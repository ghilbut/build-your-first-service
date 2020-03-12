resource aws_ecr_repository django {
  name = "django"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    map(
      "Name", "ecr-${var.srv_name}-django"
    ),
    local.tags
  )
}
