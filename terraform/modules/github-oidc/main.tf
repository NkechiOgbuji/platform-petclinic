data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  repository_prefix = trimsuffix(var.repository_prefix, "-")
  terraform_state_key_prefixes = distinct(compact(concat(
    [trim(var.terraform_state_key_prefix, "/")],
    [for prefix in var.terraform_state_key_prefixes : trim(prefix, "/")]
  )))
  create_terraform_state_policy = var.terraform_state_bucket_name != "" && length(local.terraform_state_key_prefixes) > 0

  github_subjects = distinct(flatten([
    for repo in var.github_repositories :
    concat([
      for branch in repo.branches :
      "repo:${repo.owner}/${repo.name}:ref:refs/heads/${branch}"
      ], [
      for environment in repo.environments :
      "repo:${repo.owner}/${repo.name}:environment:${environment}"
    ])
  ]))

  role_name = coalesce(var.role_name, "${var.name_prefix}-github-actions")
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_subjects
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_iam_policy_document" "github_ecr_push" {
  statement {
    sid    = "ReadCallerIdentity"
    effect = "Allow"

    actions = [
      "sts:GetCallerIdentity"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AuthenticateToEcr"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "PushAndPullPrefixedImages"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ecr:*:${data.aws_caller_identity.current.account_id}:repository/${local.repository_prefix}-*"
    ]
  }

  statement {
    sid    = "DescribeEksClusters"
    effect = "Allow"

    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "UpdateOpenAiRuntimeSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:PutSecretValue"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:${var.name_prefix}/*/terraform/openai-api-key-*"
    ]
  }
}

resource "aws_iam_policy" "github_ecr_push" {
  name        = "${var.name_prefix}-github-ecr-push-policy"
  description = "Allow GitHub Actions to push Docker images to ECR"
  policy      = data.aws_iam_policy_document.github_ecr_push.json
  tags        = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "github_ecr_push" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_ecr_push.arn

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_iam_policy_document" "terraform_state" {
  count = local.create_terraform_state_policy ? 1 : 0

  statement {
    sid    = "GetTerraformStateBucketLocation"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.terraform_state_bucket_name}"
    ]
  }

  statement {
    sid    = "ListTerraformStatePrefix"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.terraform_state_bucket_name}"
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = flatten([
        for prefix in local.terraform_state_key_prefixes : [
          prefix,
          "${prefix}/*"
        ]
      ])
    }
  }

  statement {
    sid    = "ManageTerraformStateObjects"
    effect = "Allow"

    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      for prefix in local.terraform_state_key_prefixes :
      "arn:${data.aws_partition.current.partition}:s3:::${var.terraform_state_bucket_name}/${prefix}/*"
    ]
  }

  dynamic "statement" {
    for_each = var.terraform_state_kms_key_arn != "" ? [var.terraform_state_kms_key_arn] : []

    content {
      sid    = "UseTerraformStateKmsKey"
      effect = "Allow"

      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:GenerateDataKey"
      ]

      resources = [statement.value]
    }
  }
}

resource "aws_iam_policy" "terraform_state" {
  count = local.create_terraform_state_policy ? 1 : 0

  name        = "${var.name_prefix}-github-terraform-state-policy"
  description = "Allow GitHub Actions to read and update Terraform remote state"
  policy      = data.aws_iam_policy_document.terraform_state[0].json
  tags        = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "terraform_state" {
  count = local.create_terraform_state_policy ? 1 : 0

  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_state[0].arn

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_iam_policy_document" "platform_terraform" {
  count = var.enable_platform_terraform_permissions ? 1 : 0

  statement {
    sid    = "ReadCallerIdentity"
    effect = "Allow"

    actions = [
      "sts:GetCallerIdentity"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManagePlatformAwsServices"
    effect = "Allow"

    actions = [
      "acm:*",
      "cloudwatch:*",
      "ec2:*",
      "ecr:*",
      "eks:*",
      "elasticloadbalancing:*",
      "logs:*",
      "rds:*",
      "route53:*",
      "secretsmanager:*",
      "tag:*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManagePlatformIam"
    effect = "Allow"

    actions = [
      "iam:*"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy/${var.name_prefix}*",
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.name_prefix}*",
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/*",
      "arn:${data.aws_partition.current.partition}:iam::aws:policy/*"
    ]
  }

  statement {
    sid    = "ListIamResources"
    effect = "Allow"

    actions = [
      "iam:List*",
      "iam:GetAccountSummary"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CreateServiceLinkedRoles"
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "platform_terraform" {
  count = var.enable_platform_terraform_permissions ? 1 : 0

  name        = "${var.name_prefix}-github-platform-terraform-policy"
  description = "Allow GitHub Actions to manage the platform Terraform stack"
  policy      = data.aws_iam_policy_document.platform_terraform[0].json
  tags        = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "platform_terraform" {
  count = var.enable_platform_terraform_permissions ? 1 : 0

  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.platform_terraform[0].arn

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset(var.additional_policy_arns)

  role       = aws_iam_role.github_actions.name
  policy_arn = each.value
}