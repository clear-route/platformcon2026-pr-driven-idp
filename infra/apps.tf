locals {
  apps = distinct([for app in fileset("${path.module}/../applications/", "**") : split("/", app)[0]])
  ecrs = ["frontend", "backend", "migration"] # each app has at least 3 ECRs

  overwrite_ecrs = {
    demo-app = ["frontend"]
  }

  matrix = flatten([
    for k, v in local.apps : [
      for e in try(local.overwrite_ecrs[k], toset(local.ecrs)) : {
        app       = k
        component = e
      }
    ]
  ])

}

resource "aws_ecr_repository" "this" {
  for_each = toset([for k in local.matrix : "${k.app}-${k.component}"])

  name                 = "${each.key}-${var.env}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_secretsmanager_secret" "app_secrets" {
  for_each = toset(local.apps)

  name = "constellation/${each.key}/${var.env}"
}

resource "aws_secretsmanager_secret" "app_secrets_preview" {
  for_each = toset(local.apps)

  name = "constellation/${each.key}/preview"
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = toset([for k in local.matrix : "${k.app}-${k.component}"])

  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Delete untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 100
        description  = "Keep only the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "this" {
  for_each = toset([for k in local.matrix : "${k.app}-${k.component}"])

  name = "${each.key}-${var.env}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:DescribeImages"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
        ]
        Resource = aws_ecr_repository.this[each.key].arn
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:constellation/renovate*"
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:constellation/github-app*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${var.region}.amazonaws.com"
          }
        }
      }
    ]
  })

}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "this" {
  for_each = {
    for k in local.matrix : "${k.app}-${k.component}" => k.app
  }

  name = "${each.key}-${var.env}"

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
          },
          "StringLike" = {
            "token.actions.githubusercontent.com:sub" = "repo:clear-route/${each.value}:*"
          }
        }
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = toset([for k in local.matrix : "${k.app}-${k.component}"])

  role       = aws_iam_role.this[each.key].name
  policy_arn = aws_iam_policy.this[each.key].arn
}
