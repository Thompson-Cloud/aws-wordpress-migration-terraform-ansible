resource "aws_security_group" "wordpress" {
  name        = "wordpress-ec2-sg"
  description = "Security group for the WordPress EC2 instance"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "wordpress-ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "wordpress_http" {
  security_group_id = aws_security_group.wordpress.id

  description = "Allow HTTP traffic to WordPress"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "wordpress_outbound" {
  security_group_id = aws_security_group.wordpress.id

  description = "Allow outbound traffic from WordPress EC2"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_security_group" "rds" {
  name        = "wordpress-rds-sg"
  description = "Security group for the WordPress RDS database"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "wordpress-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_mysql" {
  security_group_id = aws_security_group.rds.id

  description                  = "Allow MySQL only from WordPress EC2"
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.wordpress.id
}