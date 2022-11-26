resource "aws_s3_bucket" "cloudfront" {
  provider = aws.s3
  bucket   = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "cloudfront" {
  provider                = aws.s3
  bucket                  = aws_s3_bucket.cloudfront.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "bucket_content" {
  provider     = aws.s3
  for_each     = fileset("./${var.content_source}/", "*")
  bucket       = aws_s3_bucket.cloudfront.id
  key          = each.value
  source       = "./${var.content_source}/${each.value}"
  content_type = lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.value).extension, "application/octet-stream")
  etag         = filemd5("./${var.content_source}/${each.value}")
}

resource "aws_s3_bucket_policy" "allow_cloudfront_access" {
  depends_on = [
    aws_cloudfront_distribution.s3_distribution
  ]
  provider = aws.s3
  bucket   = aws_s3_bucket.cloudfront.id
  policy   = data.aws_iam_policy_document.allow_cloudfront_access.json
}

data "aws_iam_policy_document" "allow_cloudfront_access" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${var.cloudfront_account}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"]
    }
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  provider = aws.cloudfront

  origin {
    domain_name              = aws_s3_bucket.cloudfront.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.cloudfront.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_distribution.id

  }
  aliases             = ["${var.bucket_name}.${var.domain_name}"]
  enabled             = true
  default_root_object = var.default_root_object ? var.root_object_name : null

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.cloudfront.bucket_regional_domain_name
    viewer_protocol_policy = "allow-all"
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.managed.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }

  }

  viewer_certificate {
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    acm_certificate_arn            = aws_acm_certificate_validation.cname_cert.certificate_arn
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "s3_distribution" {
  provider                          = aws.cloudfront
  name                              = aws_s3_bucket.cloudfront.bucket_regional_domain_name
  description                       = "S3 origin access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"

}

resource "aws_acm_certificate" "cname_cert" {
  provider          = aws.acm
  domain_name       = "${var.bucket_name}.${var.domain_name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "cname_validation" {
  provider = aws.cloudfront
  for_each = {
    for dvo in aws_acm_certificate.cname_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "cname_cert" {
  provider                = aws.acm
  certificate_arn         = aws_acm_certificate.cname_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cname_validation : record.fqdn]
}

resource "aws_route53_record" "cname_alternate" {
  provider = aws.cloudfront
  zone_id  = data.aws_route53_zone.main.zone_id
  name     = var.bucket_name
  type     = "CNAME"
  ttl      = 300
  records  = [aws_cloudfront_distribution.s3_distribution.domain_name]
}
