# Infrastructure definitions

provider "aws" {
  version = "~> 4.24.0"
  region  = var.aws_region
}

# Local vars
locals {
  default_lambda_timeout = 10

  default_lambda_log_retention = 1

  min_ttl = 0
  max_ttl = 86400
  default_ttl = 3600
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "lambda-bucket-assets-12345678"
  acl           = "private"
}

module "lambda_origin" {
  source               = "./modules/lambda"
  code_src             = "../functions/default/main.zip"
  bucket_id            = aws_s3_bucket.lambda_bucket.id
  timeout              = local.default_lambda_timeout
  function_name        = "Origin-function"
  runtime              = "nodejs14.x"
  handler              = "dist/index.handler"
  publish              = true
  alias_name           = "default-fn-dev"
  alias_description    = "Alias for default function"
  environment_vars = {
    DefaultRegion   = var.aws_region
  }
}

resource "aws_lambda_function_url" "origin" {
  function_name      = module.lambda_origin.lambda[0].function_name
  qualifier         = "default-fn-dev"
  # For testing purpose we won’t have authorization
  authorization_type = "NONE"
}

resource "aws_cloudfront_origin_request_policy" "custom" {
  name    = "custom-origin-request-policy"
  comment = "Custom origin request policy"
  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["X-Very-Secret-Client-Token"]
    }
  }
  cookies_config {
    cookie_behavior = "none"
  }
  query_strings_config {
    query_string_behavior = "none"
  }
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    # This is required because "domain_name" needs to be in a specific format
    domain_name = replace(replace(aws_lambda_function_url.origin.function_url, "https://", ""), "/", "")
    origin_id = module.lambda_origin.lambda[0].function_name

    custom_origin_config {
      https_port = 443
      http_port = 80
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = module.lambda_origin.lambda[0].function_name
    viewer_protocol_policy   = "redirect-to-https"
    min_ttl                  = local.min_ttl
    default_ttl              = local.default_ttl
    max_ttl                  = local.max_ttl
    origin_request_policy_id = aws_cloudfront_origin_request_policy.custom.id
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  price_class = var.cf_price_class
  enabled = true
  is_ipv6_enabled     = true
  comment             = "origin request policy test"
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
