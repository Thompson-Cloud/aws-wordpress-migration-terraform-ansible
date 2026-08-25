output "wordpress_instance_id" {
  description = "EC2 instance ID for the WordPress server."
  value       = aws_instance.wordpress.id
}

output "wordpress_public_ip" {
  description = "Public IPv4 address of the WordPress server."
  value       = aws_instance.wordpress.public_ip
}

output "rds_endpoint" {
  description = "RDS endpoint used by WordPress to connect to MySQL."
  value       = aws_db_instance.wordpress.address
}

output "migration_bucket_name" {
  description = "S3 bucket used to store migration artifacts."
  value       = aws_s3_bucket.migration.bucket
}

output "rds_master_secret_arn" {
  description = "Secrets Manager ARN containing the RDS master credentials."
  value       = aws_db_instance.wordpress.master_user_secret[0].secret_arn
}