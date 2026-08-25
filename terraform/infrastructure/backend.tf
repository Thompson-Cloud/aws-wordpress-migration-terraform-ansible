terraform {
  backend "s3" {
    bucket       = "thompson-wordpress-tfstate-202937691499"
    key          = "wordpress-migration/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}