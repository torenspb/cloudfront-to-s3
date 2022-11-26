variable "bucket_name" {
  type        = string
  description = "Name of S3 bucket to serve content from"
}

variable "domain_name" {
  type        = string
  description = "Top-level domain name to be used by sub-domains"
}

variable "content_source" {
  type        = string
  description = "Folder with content to place to S3 bucket"
}

variable "cloudfront_account" {
  type        = string
  description = "AWS account where CloudFront distribution is created"
}

variable "default_root_object" {
  default     = false
  type        = bool
  description = "Enable of disable Cloudfront default root object"
}

variable "root_object_name" {
  type        = string
  description = "Cloudfront default root object name"
}