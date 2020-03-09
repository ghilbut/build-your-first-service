
################################################################
##
##  Develop
##

##--------------------------------------------------------------
##  Security Group

resource aws_security_group mysql {
  name = "byfs-mysql-develop"
  description = "Allow MySQL inbound traffic"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = merge(
    map(
      "Name",  "sg-byfs-mysql-develop",
    ),
    local.tags, 
  )
}

##--------------------------------------------------------------
##  Parameter Group

resource aws_db_parameter_group mysql {
  name   = "byfs-mysql"
  family = "mysql5.7"

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  tags = merge(
    map(
      "Name",  "pg-byfs-mysql",
    ),
    local.tags, 
  )
}

##--------------------------------------------------------------
##  MySQL

resource random_string mysql_develop_username {
  length = 8
  special = false
}

resource random_password mysql_develop_password {
  length = 12
  special = true
  override_special = "!@#$%^&*()"
}

resource aws_db_instance develop {
  allocated_storage     = 20
  availability_zone     = "ap-northeast-2a"
  storage_type          = "gp2"
  engine                = "mysql"
  engine_version        = "5.7"
  instance_class        = "db.t3.micro"
  name                  = "byfs"
  username              = random_string.mysql_develop_username.result
  password              = random_password.mysql_develop_password.result
  parameter_group_name  = aws_db_parameter_group.mysql.id

  identifier = "rds-byfs-develop"

  skip_final_snapshot = true
  publicly_accessible = true

  vpc_security_group_ids = [
    aws_security_group.mysql.id,
  ]

  tags = merge(
    map(
      "Name", "rds-byfs-mysql-develop",
    ),
    local.tags, 
  )
}
