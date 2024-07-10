# Roles
resource "aws_iam_role" "app-tier-role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Policies
resource "aws_iam_policy" "rds-secret-permissions" {
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:${local.region}:${data.aws_caller_identity.account-identity.account_id}:secret:rds-master-creds-*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "kms:Decrypt"
        ],
        "Resource": "arn:aws:kms:${local.region}:${data.aws_caller_identity.account-identity.account_id}:key/*"
      }
    ]
  })
}

# Role-Policy Attachments
resource "aws_iam_role_policy_attachment" "instance-role-policy-attachment" {
  policy_arn = aws_iam_policy.rds-secret-permissions.arn
  role       = aws_iam_role.app-tier-role.name
}

# Profiles
resource "aws_iam_instance_profile" "app-instance-profile" {
  name = "app_tier_instance_profil"
  role = aws_iam_role.app-tier-role.name
}

data "aws_caller_identity" "account-identity" {}