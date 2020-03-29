################################################################
##
##  AWS Route 53
##

resource aws_route53_record mysql {
  zone_id = data.aws_route53_zone.private.zone_id
  name    = "${local.srv_name}-${local.stage}.db.${local.domain_name}"

  type    = "CNAME"
  ttl     = 5
  records = [
    data.terraform_remote_state.common.outputs.mysql_develop_address
  ]
}



################################################################
##
##  AWS Secret Manager
##

##--------------------------------------------------------------
##  host name

resource aws_secretsmanager_secret mysql_host {
  name = "byfs-${local.stage}-mysql-host"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version mysql_host {
  secret_id     = aws_secretsmanager_secret.mysql_host.id
  secret_string = aws_route53_record.mysql.name
}

##--------------------------------------------------------------
##  database name

resource aws_secretsmanager_secret mysql_name {
  name = "byfs-${local.stage}-mysql-name"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version mysql_name {
  secret_id     = aws_secretsmanager_secret.mysql_name.id
  secret_string = "${local.stage}"
}

##--------------------------------------------------------------
##  port

resource aws_secretsmanager_secret mysql_port {
  name = "byfs-${local.stage}-mysql-port"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version mysql_port {
  secret_id     = aws_secretsmanager_secret.mysql_port.id
  secret_string = "3306"
}

##--------------------------------------------------------------
##  username

resource aws_secretsmanager_secret mysql_username {
  name = "byfs-${local.stage}-mysql-username"
  recovery_window_in_days = 0
}

resource random_string mysql_username {
  length  = 8
  number  = false
  special = false
}

resource aws_secretsmanager_secret_version mysql_username {
  secret_id     = aws_secretsmanager_secret.mysql_username.id
  secret_string = random_string.mysql_username.result
}

##--------------------------------------------------------------
##  password

resource aws_secretsmanager_secret mysql_password {
  name = "byfs-${local.stage}-mysql-password"
  recovery_window_in_days = 0
}

resource random_string mysql_password {
  length           = 12
  override_special = "!@#$%^&*()"
}

resource aws_secretsmanager_secret_version mysql_password {
  secret_id     = aws_secretsmanager_secret.mysql_password.id
  secret_string = random_string.mysql_password.result
}



################################################################
##
##  MySQL logical database
##

resource mysql_database default {
  default_character_set = "utf8mb4"
  default_collation     = "utf8mb4_unicode_ci"
  name                  = local.stage
}

resource mysql_user default {
  user               = random_string.mysql_username.result
  host               = "%"
  plaintext_password = random_string.mysql_password.result
}

resource mysql_grant default {
  user       = mysql_user.default.user
  host       = mysql_user.default.host
  database   = mysql_database.default.name
  privileges = ["ALL"]
}
