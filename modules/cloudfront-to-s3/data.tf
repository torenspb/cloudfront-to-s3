data "aws_cloudfront_cache_policy" "managed" {
  name = "Managed-CachingOptimized"
}

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

