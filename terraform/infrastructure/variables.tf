variable "aws_region" {
  description = "AWS region where the migration infrastructure will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the migration VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet hosting the WordPress EC2 instance."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_db_subnet_a_cidr" {
  description = "CIDR block for the first private RDS subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_db_subnet_b_cidr" {
  description = "CIDR block for the second private RDS subnet."
  type        = string
  default     = "10.0.3.0/24"
}
variable "ec2_instance_type" {
  description = "EC2 instance type for the WordPress application server."
  type        = string
  default     = "t3.micro"
}

variable "db_name" {
  description = "Name of the WordPress MySQL database."
  type        = string
  default     = "company_db"
}

variable "db_username" {
  description = "Master username for the RDS MySQL instance."
  type        = string
  default     = "admin"
}

variable "db_instance_class" {
  description = "RDS instance class for the WordPress database."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated RDS storage in GiB."
  type        = number
  default     = 20
}