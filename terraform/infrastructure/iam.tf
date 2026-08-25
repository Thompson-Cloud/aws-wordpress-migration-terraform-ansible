resource "aws_iam_role" "ec2" {
  name = "wordpress-migration-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "wordpress-migration-ec2-role"
  }
}
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "migration_s3" {
  statement {
    sid = "ListMigrationBucket"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.migration.arn
    ]
  }

  statement {
    sid = "ReadMigrationObjects"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.migration.arn}/*"
    ]
  }
}
resource "aws_iam_policy" "migration_s3" {
  name        = "wordpress-migration-s3-read"
  description = "Allow WordPress EC2 to read the migration backup from the migration S3 bucket"
  policy      = data.aws_iam_policy_document.migration_s3.json
}
resource "aws_iam_role_policy_attachment" "migration_s3" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.migration_s3.arn
}
resource "aws_iam_instance_profile" "ec2" {
  name = "wordpress-migration-ec2-profile"
  role = aws_iam_role.ec2.name
}

data "aws_iam_policy_document" "ansible_controller" {
  statement {
    sid = "ManageSSMSessions"

    actions = [
      "ssm:StartSession",
      "ssm:ResumeSession",
      "ssm:TerminateSession"
    ]

    resources = ["*"]
  }

  statement {
    sid = "ListAnsibleTransferBucket"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.ansible_transfer.arn
    ]
  }

  statement {
    sid = "ManageAnsibleTransferObjects"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.ansible_transfer.arn}/*"
    ]
  }


  statement {
    sid = "ReadRDSMasterSecret"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      aws_db_instance.wordpress.master_user_secret[0].secret_arn
    ]
  }
}

resource "aws_iam_policy" "ansible_controller" {
  name        = "wordpress-migration-ansible-controller"
  description = "Allow the Ansible controller to connect through SSM and use the temporary transfer bucket"
  policy      = data.aws_iam_policy_document.ansible_controller.json
}