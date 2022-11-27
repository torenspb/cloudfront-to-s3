# cloudfront-to-s3
This repository contains a tiny `cloudfront-to-s3` module along with an example of its usage.  
Using the module you can set up a CloudFront distribution with an alternate domain that will serve content from a private S3 bucket located in a different AWS account. This might be useful in organizations, where Internet-facing resources are deployed in a dedicated AWS account (for example, MGMT), while S3 buckets might be distributed across other accounts (for example, DEV/STAGE/PROD).  
Content from the example is available by this link - [https://cloudfront-content-to-s3.eurotunnel.cloud/](https://cloudfront-content-to-s3.eurotunnel.cloud/)

## Architecture
The following diagram shows the architecture behind the solution:
![AWS diagram](./img/cloudfront-to-s3.png)

A new private S3 bucket is created in `AWS Account B` and then content from the provided folder is copied into that bucket.  
In `AWS Account A` a certificate for new Route53 subdomain is generated, a new Route53 `CNAME` record for provided domain pointing to a CloudFront distribution is created and the CloudFront distribution itself with the alternate name, generated certificate pointing to the private S3 bucket is also created.  

## Usage
Let's look at the `main.tf` as an example:
```
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
```
Since AWS resources are deployed in different AWS accounts, at least two AWS providers should be configured and it's expected that terraform has appropriate access to both of them. As can be found in `backend.tf`, CloudFront distribution and associated Route53 subdomain are configured within `mgmt` AWS account in this example, while private S3 bucket in `prod` account. This account should be explicitly matched with `aws.cloudfront` and `aws.s3` aliases when calling the module.  
Other parameters include:  
`content_source` - folder where files to be stored in S3 bucket are located;  
`bucket_name` - S3 bucket name;  
`default_root_object` - controls whether distribution should have a default root object;  
`root_object_name` - default root object name;  
`domain_name` - domain name for which a new subdomain will be created and associated with CloudFront distribution;  
`cloudfront_account` - AWS account id of account where CloudFront distribution is created (this is needed to set up S3 bucket policy);  

## Fresh AWS account installation guide
Following steps describe actions to be taken in order to deploy the solution on a newly created AWS account:
1. Create AWS organization  
since module components are deployed in different AWS accounts, once a new AWS account is created, create an AWS organization - [https://docs.aws.amazon.com/organizations/latest/userguide/orgs_getting-started.html?org_product_gs_orgsetup](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_getting-started.html?org_product_gs_orgsetup)
2. Create a second AWS account within your AWS organization  
you can give that account a `PROD` name, for example
3. Register domain and configure hosted zone under the first AWS account  
a subdomain will be created for this domain to access private S3 bucket  
[https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/registrar.html](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/registrar.html)  
[https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html)  
4. Create a new IAM user with programmatic access to be used by terraform  
add appropriate permissions (`AdministratorAccess`, for example)  
5. Configure two terraform providers  
the first provider will be used to access your first AWS account where CloudDistribution will be created;  
the second provided will be used to access the second AWS account where a private S3 bucket will be created;  
an appropriate `role_arn` needs to be associated with the second provider in order for terraform to configure resources under the second AWS account. For example,  
```
# s3 account
provider "aws" {
  region = "eu-north-1"
  alias  = "prod"
  assume_role {
    role_arn     = "arn:aws:iam::987654321000:role/OrganizationAccountAccessRole"
    session_name = "terraform"
  }
  default_tags {
    tags = {
      Environment = "prod"
    }
  }
}
```
6. Configure module inputs and map configured providers with `aws.cloudfront` and `aws.s3` configured in the module  
```
  providers = {
    aws.cloudfront = aws
    aws.s3         = aws.prod
  }
```

## #roadmap
- add an ability to use the deployment without domain name (using CloudFront domain name);
