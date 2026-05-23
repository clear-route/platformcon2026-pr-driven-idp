data "aws_caller_identity" "current" {}

locals {
  env_oidc_subject = {
    dev     = "repo:clear-route/platformcon2026-pr-driven-idp:ref:refs/heads/main"
    preview = "repo:clear-route/platformcon2026-pr-driven-idp:pull_request"
    prod    = "repo:clear-route/platformcon2026-pr-driven-idp:ref:refs/tags/*"
  }
}

resource "aws_iam_role" "this" {
  for_each = local.env_oidc_subject

  name = "platformcon2026-demo-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = each.value
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "argocd_diff" {
  name = "platformcon2026-argocd-diff"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:clear-route/platformcon2026-pr-driven-idp:pull_request"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "argocd_diff" {
  name = "platformcon2026-argocd-diff"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:constellation/github-app-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "argocd_diff" {
  role       = aws_iam_role.argocd_diff.name
  policy_arn = aws_iam_policy.argocd_diff.arn
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k in local.matrix : "${k.app}-${k.component}-${k.env}" => k }

  role       = aws_iam_role.this[each.value.env].name
  policy_arn = aws_iam_policy.this[each.key].arn
}

resource "aws_iam_policy" "this" {
  for_each = toset([for k in local.matrix : "${k.app}-${k.component}-${k.env}"])

  name = each.key

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
        ]
        Resource = aws_ecr_repository.this[each.key].arn
      }
    ]
  })
}
