resource mysql_database default {
  default_character_set = "utf8mb4"
  default_collation     = "utf8mb4_unicode_ci"
  name                  = local.stage
}

resource mysql_user default {
  user               = var.mysql_username
  host               = "%"
  plaintext_password = var.mysql_password
}

resource mysql_grant default {
  user       = mysql_user.default[count.index].user
  host       = mysql_user.default[count.index].host
  database   = mysql_database.default[count.index].name
  privileges = ["ALL"]
}
