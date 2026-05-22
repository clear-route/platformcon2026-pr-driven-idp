terraform {
  required_version = ">=1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.46.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.12.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_secretsmanager_secret_version" "github_app" {
  secret_id = "constellation/github-app"
}

provider "github" {
  owner = "clear-route"

  app_auth {
    id              = jsondecode(data.aws_secretsmanager_secret_version.github_app.secret_string)["app_id"]
    installation_id = jsondecode(data.aws_secretsmanager_secret_version.github_app.secret_string)["installation_id"]
    pem_file        = jsondecode(data.aws_secretsmanager_secret_version.github_app.secret_string)["private_key_pem"]
  }
}
