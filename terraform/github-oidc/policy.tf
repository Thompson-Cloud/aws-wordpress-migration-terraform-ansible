data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_migration_permissions" {

  # ---------------------------------------------------------
  # Discover existing EC2 application targets
  # ---------------------------------------------------------
  statement {
    sid = "DiscoverEC2Targets"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags"
    ]

    resources = ["*"]
  }

  # ---------------------------------------------------------
  # Discover existing RDS database targets
  # ---------------------------------------------------------
  statement {
    sid = "DiscoverRDSTargets"

    actions = [
      "rds:DescribeDBInstances",
      "rds:ListTagsForResource"
    ]

    resources = ["*"]
  }

  # ---------------------------------------------------------
  # Verify SSM readiness and manage Ansible SSM sessions
  # ---------------------------------------------------------
  statement {
    sid = "UseSystemsManager"

    actions = [
      "ssm:DescribeInstanceInformation",
      "ssm:StartSession",
      "ssm:ResumeSession",
      "ssm:TerminateSession"
    ]

    resources = ["*"]
  }

  # ---------------------------------------------------------
  # Read approved WordPress migration artifacts
  # ---------------------------------------------------------
  statement {
    sid = "ListMigrationBuckets"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    resources = [
      for bucket in var.allowed_migration_buckets :
      "arn:aws:s3:::${bucket}"
    ]
  }

  statement {
    sid = "ReadMigrationArtifacts"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      for bucket in var.allowed_migration_buckets :
      "arn:aws:s3:::${bucket}/*"
    ]
  }

  # ---------------------------------------------------------
  # Use temporary S3 buckets for Ansible over SSM
  # ---------------------------------------------------------
  statement {
    sid = "ListAnsibleTransferBuckets"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    resources = [
      for bucket in var.allowed_ansible_transfer_buckets :
      "arn:aws:s3:::${bucket}"
    ]
  }

  statement {
    sid = "ManageAnsibleTransferObjects"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = [
      for bucket in var.allowed_ansible_transfer_buckets :
      "arn:aws:s3:::${bucket}/*"
    ]
  }

  # ---------------------------------------------------------
  # Read RDS-managed Secrets Manager credentials
  # ---------------------------------------------------------
  statement {
    sid = "ReadRDSMasterSecret"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:rds!*"
    ]
  }
}

resource "aws_iam_policy" "github_migration" {
  name        = "github-wordpress-migration-policy"
  description = "Permissions required by the reusable WordPress migration workflow"

  policy = data.aws_iam_policy_document.github_migration_permissions.json
}

resource "aws_iam_role_policy_attachment" "github_migration" {
  role       = aws_iam_role.github_migration.name
  policy_arn = aws_iam_policy.github_migration.arn
}