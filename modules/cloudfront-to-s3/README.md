## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.41.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.acm"></a> [aws.acm](#provider\_aws.acm) | 4.41.0 |
| <a name="provider_aws.cloudfront"></a> [aws.cloudfront](#provider\_aws.cloudfront) | 4.41.0 |
| <a name="provider_aws.s3"></a> [aws.s3](#provider\_aws.s3) | 4.41.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cname_cert](https://registry.terraform.io/providers/hashicorp/aws/4.41.0/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cname_cert](https://registry.terraform.io/providers/hashicorp/aws/4.41.0/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.s3_distribution](https://registry.terraform.io/providers/hashicorp/aws/4.41.0/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.s3_distribution](https://registry.terraform.io/providers/hashicorp/aws/4.41.0/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_route53_record.cname_alternate](https://registry.terraform.io/providers/hashicorp/aws/4.41.0/docs/resources/route53_record) | resource |
| [aws_route53_record.cname_validation](https://registry.terraform.io/providers/hashicorp/aws/4.41.0/docs/resources/route53_record) | resource |
| [aws_s3_bucket.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/4.41.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.allow_cloudfront_access](https://registry.terraform.io/providers/hashicorp/aws/4.41.0/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/4.41.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_object.bucket_content](https://registry.terraform.io/providers/hashicorp/aws/4.41.0/docs/resources/s3_object) | resource |
| [aws_cloudfront_cache_policy.managed](https://registry.terraform.io/providers/hashicorp/aws/4.41.0/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_iam_policy_document.allow_cloudfront_access](https://registry.terraform.io/providers/hashicorp/aws/4.41.0/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.main](https://registry.terraform.io/providers/hashicorp/aws/4.41.0/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of S3 bucket to serve content from | `string` | n/a | yes |
| <a name="input_cloudfront_account"></a> [cloudfront\_account](#input\_cloudfront\_account) | AWS account where CloudFront distribution is created | `string` | n/a | yes |
| <a name="input_content_source"></a> [content\_source](#input\_content\_source) | Folder with content to place to S3 bucket | `string` | n/a | yes |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | Enable of disable Cloudfront default root object | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Top-level domain name to be used by sub-domains | `string` | n/a | yes |
| <a name="input_root_object_name"></a> [root\_object\_name](#input\_root\_object\_name) | Cloudfront default root object name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_distribution_url"></a> [distribution\_url](#output\_distribution\_url) | n/a |