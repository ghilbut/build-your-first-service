terraform {
  required_version = "~> 0.12.6"

  backend s3 {
    # s3://<bucket>/<workspace_key_prefix>/<workspace-name>/<key>
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

