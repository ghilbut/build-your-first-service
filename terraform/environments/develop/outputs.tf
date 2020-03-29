output mysql_address {
  value       = aws_route53_record.mysql.name
  description = "MySQL address for current stage"
}

output mysql_name {
  value       = mysql_database.default.name
  description = "MySQL database name for current stage"
}

output mysql_username {
  value       = random_string.mysql_username.result
  description = "MySQL username for current stage"
  sensitive   = true
}

output mysql_password {
  value       = random_string.mysql_password.result
  description = "MySQL password for current stage"
  sensitive   = true
}
