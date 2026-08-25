provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-wordpress-migration"
      Environment = "lab"
      ManagedBy   = "Terraform"
    }
  }
}