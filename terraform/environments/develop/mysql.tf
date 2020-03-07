resource mysql_database default {
  count = local.ignore_when_local_stage

  default_character_set = "utf8mb4"
  default_collation     = "utf8mb4_unicode_ci"
  name                  = local.stage
}

resource mysql_user default {
  count = local.ignore_when_local_stage

  user               = var.mysql_username
  host               = "%"
  plaintext_password = var.mysql_password
}

resource mysql_grant default {
  count = local.ignore_when_local_stage

  user       = mysql_user.default[count.index].user
  host       = mysql_user.default[count.index].host
  database   = mysql_database.default[count.index].name
  privileges = ["ALL"]
}
