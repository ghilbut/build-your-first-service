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
