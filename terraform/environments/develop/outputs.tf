output mysql_address {
  value       = aws_route53_record.mysql.name
  description = "MySQL address for develop environment"
}

output mysql_username {
  value       = var.mysql_username
  description = "MySQL username for stage"
  sensitive   = true
}

output mysql_password {
  value       = var.mysql_password
  description = "MySQL password for stage"
  sensitive   = true
}
