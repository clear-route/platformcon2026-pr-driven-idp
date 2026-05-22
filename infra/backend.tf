terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    region  = "ap-southeast-2"
    encrypt = "true"
    bucket  = "clearroute-test-terraform-state"
    key     = "platformcon.terraform.tfstate"
  }
}
