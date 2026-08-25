# Retrieve the latest Amazon Linux 2023 AMI
# from AWS's public SSM Parameter Store
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# WordPress application server
resource "aws_instance" "wordpress" {
  ami           = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.wordpress.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  associate_public_ip_address = true

  # Require IMDSv2 for instance metadata access
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Encrypted general-purpose root volume
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 10
  }

  tags = {
    Name = "wordpress-migration-ec2"
  }
}