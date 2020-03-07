terraform {
  required_version = "~> 0.12.6"

  backend s3 {
    bucket  = "byfs-terraform"
    key     = "terraform.tfstate"

    profile = "byfs"
    region  = "ap-northeast-2"
    encrypt = true
    # dynamodb_table =
  }
}


provider aws {
  region  = var.aws_region
  profile = var.aws_profile
}


locals {
  tags = {
    organization = var.organization
    owner = "terraform"
    "terraform:environment" = "common"
  }
}
