terraform {
  required_version = "~> 0.12.6"

  backend s3 {
    # s3://<bucket>/<workspace_key_prefix>/<workspace-name>/<key>
    bucket               = "byfs-terraform"
    workspace_key_prefix = "develop"
    key                  = "terraform.tfstate"

    profile        = "byfs"
    region         = "ap-northeast-2"
    encrypt        = true
    # dynamodb_table =
  }
}


provider aws {
  region  = var.aws_region
  profile = var.aws_profile
}


data terraform_remote_state common {
  backend   = "s3"
  workspace = "default"

  config = {
    bucket  = "byfs-terraform"
    key     = "terraform.tfstate"

    profile = "byfs"
    region  = "ap-northeast-2"
    encrypt = true
  }
}


provider mysql {
  endpoint = "${data.terraform_remote_state.common.outputs.mysql_develop_address}:3306"
  username = data.terraform_remote_state.common.outputs.mysql_develop_username
  password = data.terraform_remote_state.common.outputs.mysql_develop_password
}


locals {
  ignore_on_local_stage = (terraform.workspace == "default" ? 0 : 1)

  srv_name = data.terraform_remote_state.common.outputs.srv_name
  domain_name = data.terraform_remote_state.common.outputs.domain_name

  stage = (terraform.workspace == "default" ? "local" : terraform.workspace)
  tags = {
    organization = var.organization
    owner = "terraform"
    stage = local.stage
    "terraform:environment" = "develop"
    "terraform:workspace" = terraform.workspace
  }
}
