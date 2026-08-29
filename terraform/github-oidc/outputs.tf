output "github_migration_role_arn" {
  description = "IAM role ARN assumed by the GitHub Actions migration workflow."
  value       = aws_iam_role.github_migration.arn
}

