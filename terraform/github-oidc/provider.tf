provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "aws-wordpress-migration"
      ManagedBy = "Terraform"
      Component = "github-oidc"
    }
  }
}
