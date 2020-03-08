output domain_name {
  value = var.domain_name
}

output srv_name {
  value = var.srv_name
}

output mysql_develop_address {
  value = aws_db_instance.develop.address
  description = "MySQL address for develop environment"
  sensitive   = true
}

output mysql_develop_username {
  value = random_string.mysql_develop_username.result
  description = "MySQL admin username for develop environment"
  sensitive   = true
}

output mysql_develop_password {
  value = random_password.mysql_develop_password.result
  description = "MySQL admin password for develop environment"
  sensitive   = true
}
