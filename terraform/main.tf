terraform {
  backend "s3" {
    bucket       = "bedrock-tfstate-alt-soe-025-1516"
    key          = "infrastructure/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}