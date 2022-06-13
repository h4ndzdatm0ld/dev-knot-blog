terraform {
  cloud {
    organization = "crunchy-org"
    workspaces {
      name = "dev-knot"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_amplify_app" "dev-knot-app" {
  name                     = var.blog_name
  repository               = var.repository
  access_token             = var.gh_access_token
  enable_branch_auto_build = true
  platform                 = "WEB"
  build_spec               = <<-EOT
    version: 0.1
    frontend:
      phases:
        build:
          commands:
            - "cd dev-knot && serve --config ./config.toml -e production"
      artifacts:
        baseDirectory: ./dev-knot/public
        files:
          - '**/*'
      cache:
        paths: []
  EOT
  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }
  # custom_rule {
  #   source = "https://${var.blog_domain}"
  #   status = "302"
  #   source = "https://www${var.blog_domain}"
  # }
  environment_variables = {
    ENV = "dev-knot"
    "_LIVE_UPDATES" = jsonencode(
      [
        {
          pkg     = "hugo"
          type    = "hugo"
          version = "latest"
        },
      ]
    )
  }
}
# ADD Branch setup to new AWS Amplify APP Resource
resource "aws_amplify_branch" "main" {
  enable_pull_request_preview = true
  app_id                      = aws_amplify_app.dev-knot-app.id
  branch_name                 = "main"

  stage               = "PRODUCTION"
  enable_notification = true
}
resource "aws_amplify_branch" "develop" {
  enable_pull_request_preview = true
  app_id                      = aws_amplify_app.dev-knot-app.id
  branch_name                 = "develop"

  stage               = "DEVELOPMENT"
  enable_notification = true

}
# ADD Webhooks
resource "aws_amplify_webhook" "main" {
  app_id      = aws_amplify_app.dev-knot-app.id
  branch_name = aws_amplify_branch.main.branch_name
  description = "amplify-hook-main"
}
resource "aws_amplify_webhook" "DEVELOPMENT" {
  app_id      = aws_amplify_app.dev-knot-app.id
  branch_name = aws_amplify_branch.develop.branch_name
  description = "amplify-hook-develop"
}

# ACM Certificate
resource "aws_acm_certificate" "blog" {
  domain_name       = var.blog_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_acm_certificate" "https-blog" {
  domain_name       = "www.${var.blog_domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Associate Domain / SSL
resource "aws_amplify_domain_association" "dev-knot" {
  app_id      = aws_amplify_app.dev-knot-app.id
  domain_name = var.blog_domain

  # https://example.com
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = ""
  }

  # https://www.example.com
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "www"
  }
}

# CERTIFICATE AND ROUTE 53
resource "aws_route53_zone" "primary" {
  name = var.blog_domain
}

resource "aws_route53_record" "blog_cert" {
  for_each = {
    for dvo in aws_acm_certificate.blog.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.primary.zone_id
}

resource "aws_route53_record" "blog" {

  zone_id = aws_route53_zone.primary.zone_id
  name    = var.blog_name
  type    = "A"

  alias {
    name                   = var.blog_domain
    zone_id                = aws_route53_zone.primary.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate_validation" "blog_cert" {
  certificate_arn         = aws_acm_certificate.blog.arn
  validation_record_fqdns = [for record in aws_route53_record.blog_cert : record.fqdn]
}
