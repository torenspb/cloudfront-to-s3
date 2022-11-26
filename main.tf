module "cloudfront-to-s3" {
  source = "./modules/cloudfront-to-s3"

  content_source      = "bucket-content"
  bucket_name         = "cloudfront-content-to-s3"
  default_root_object = true
  root_object_name    = "index.html"
  domain_name         = "eurotunnel.cloud"
  cloudfront_account  = "000123456789"
  providers = {
    aws.cloudfront = aws
    aws.s3         = aws.prod
  }
}
