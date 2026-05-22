terraform {
  required_version = ">= 1.0.0"

  # partially configured using Makefile
  backend "s3" {
    region  = "ap-southeast-2"
    encrypt = "true"
    bucket  = "clearroute-test-terraform-state"
    key     = "platformcon.terraform.tfstate"
  }
}
