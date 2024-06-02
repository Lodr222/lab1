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
	profile = "default"
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
