terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.0"
		}
	}
}

# Configure AWS provider and creds
provider "aws" {
	region = "us-east-1"
	access_key = "ASIATN5REGS7XXP66P5J"
  	secret_key = "2VPiDnCvolTdxjRygtGxL/KrYfR1wQzv9owxgwP9"
	aws_session_token = "IQoJb3JpZ2luX2VjEO7//////////wEaCXVzLXdlc3QtMiJIMEYCIQChgwgLBfyizziWcfl2G7ln+8an1agFitevCHR9Vje5tgIhAO1INHNLMmT7UGMOvia08Mgl2t4CCCYTterUvUqgqySVKq8CCHcQABoMMjM2MDU3ODAxOTE5IgxE9DR1nd/jeM2yvacqjAJFnSOm61q6QkTxKUc8e0bUtZSxVKW1KNGPdfHUkiWGcjYBIyO8oPiRPjRq9uXHWTi94kDGhm2ByYOOhUZuzZpR3pNM5UyVltZbgH++hf0gNmPBS9uXeAMuXiT8tNVpV+5MVQXpuBkaTbSI77UdDe/l2yfnFOhBUNd2t65BtXLeHIWY/y8MaomBpHT0l5hAw1REXml3h3Rkx76bMiewKaAGFy0R1Hat4YtN3CHPeUmJfevwROj9anztMDhE8DqfmxapsrMJIWcb5PhExG5huHiDPghUi5D0aFTQrK5jyPTcdpNEIlx5OGRVF1IRMpAdpXLiGll8xfwNjZig/jfZ6wXnyUcR7lSAwq5Us1OtMNTk8bIGOpwBr2R1XTsEwtC9Cv+cNpXw00nJ4kd1SPlQx8S2t4LErXArUOQSKUKjTf+iAAcoqOt3ESv1C0waykxFO7G7CBwHezHl9xwzVx1A5lkRwV76QjB+hJaKN57gBeeU/klMUGdOxgFSTHoNdM3IrqV3XuynG7voCozqK98oOMhxlmEgmLsSYOKIsA5lfkTDEGkdzvdq5Dejx4FMOcnPdE1t"
	output = json
}

# Creating bucket
resource "aws_s3_bucket" "website" {
	bucket = "lab2-lavryk"
	tags = {
		Name = "Website"
		Environment = "Dev"
	}
}

resource "aws_s3_bucket_acl" "example_acl" {
	bucket = aws_s3_bucket.website.id
	acl = "public-read"
	depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.example]
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "website_config" {
	bucket = aws_s3_bucket.website.id

	index_document {
		suffix = "index.html"
	}
	
	error_document {
		key = "error.html"
	}
}

resource "aws_s3_bucket_policy" "allow_access" {
	bucket = aws_s3_bucket.website.id
	policy = data.aws_iam_policy_document.allow_access.json
	depends_on = [aws_s3_bucket_public_access_block.example]
}

data "aws_iam_policy_document" "allow_access" {
	statement {
		principals {
			type = "AWS"
			identifiers = ["*"]
		}
	actions = [
		"s3:GetObject"
	]
	resources = [
		aws_s3_bucket.website.arn,
		"${aws_s3_bucket.website.arn}/*",
	]
  }
}

resource "aws_s3_object" "indexfile" {
	bucket = aws_s3_bucket.website.id
	key = "index.html"
	source = "./src/index.html"
	content_type = "text/html"
}

output "website_endpoint" {
	value = aws_s3_bucket_website_configuration.website_config.website_endpoint
}
