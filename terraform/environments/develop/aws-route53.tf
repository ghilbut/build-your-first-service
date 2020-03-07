data aws_route53_zone public {
  name         = local.domain_name
  private_zone = false
}

data aws_route53_zone private {
  name         = local.domain_name
  #private_zone = true
  private_zone = false
}

resource aws_route53_record mysql {
  zone_id = data.aws_route53_zone.private.zone_id
  name    = "byfs-${local.stage}.db.${local.domain_name}"

  type    = "CNAME"
  ttl     = 5
  records = [
    data.terraform_remote_state.common.outputs.mysql_develop_address
  ]
}
