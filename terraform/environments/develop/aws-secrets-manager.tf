resource aws_secretsmanager_secret mysql_host {
  name = "byfs-${local.stage}-mysql-host"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version mysql_host {
  secret_id     = aws_secretsmanager_secret.mysql_host.id
  secret_string = aws_route53_record.mysql.name
}


resource aws_secretsmanager_secret mysql_name {
  name = "byfs-${local.stage}-mysql-name"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version mysql_name {
  secret_id     = aws_secretsmanager_secret.mysql_name.id
  secret_string = "${local.stage}"
}


resource aws_secretsmanager_secret mysql_port {
  name = "byfs-${local.stage}-mysql-port"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version mysql_port {
  secret_id     = aws_secretsmanager_secret.mysql_port.id
  secret_string = "3306"
}


resource aws_secretsmanager_secret mysql_username {
  name = "byfs-${local.stage}-mysql-username"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version mysql_username {
  secret_id     = aws_secretsmanager_secret.mysql_username.id
  secret_string = var.mysql_username
}


resource aws_secretsmanager_secret mysql_password {
  name = "byfs-${local.stage}-mysql-password"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version mysql_password {
  secret_id     = aws_secretsmanager_secret.mysql_password.id
  secret_string = var.mysql_password
}
