variable "aws_region" {
  description = "AWS region used by the migration workflow."
  type        = string
  default     = "us-east-1"
}

variable "github_organization" {
  description = "GitHub organization or username that owns the repository."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the migration role."
  type        = string
}

variable "allowed_migration_buckets" {
  description = "S3 migration buckets that the GitHub migration workflow may read."
  type        = list(string)
}

variable "allowed_ansible_transfer_buckets" {
  description = "S3 buckets that GitHub Actions may use for temporary Ansible SSM transfers."
  type        = list(string)
}