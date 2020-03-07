output mysql_address {
  value       = aws_route53_record.mysql.name
  description = "MySQL address for current stage"
}

output mysql_name {
  value       = mysql_database.default.*.name
  description = "MySQL database name for current stage"
}

output mysql_username {
  value       = var.mysql_username
  description = "MySQL username for current stage"
  sensitive   = true
}

output mysql_password {
  value       = var.mysql_password
  description = "MySQL password for current stage"
  sensitive   = true
}
