/*
  1. create a bucket
  2. Disable block public access
  3. creating bucket policy
  4. origin access control
  5. upload multiple objects in the bucket
  6. S3 static website configuration
*/

# Create a S3 bucket
resource "aws_s3_bucket" "objects-bucket" {
  bucket = var.bucket_name
  tags   = var.tags
}

# Disable publoc access block
resource "aws_s3_bucket_public_access_block" "block-public" {
  bucket = aws_s3_bucket.objects-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create a bucket policy
resource "aws_s3_bucket_policy" "allow-cloudfront" {
  bucket     = aws_s3_bucket.objects-bucket.id
  depends_on = [aws_s3_bucket_public_access_block.block-public]
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "Statement1",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cloudfront.amazonaws.com"
          },
          "Action" : [
            "s3:GetObject"
          ],
          "Resource" : "${aws_s3_bucket.objects-bucket.arn}/*",
          "Condition" : {
            "ArnEquals" : {
              "aws:SourceArn" : "${aws_cloudfront_distribution.s3_distribution.arn}"
            }
          }
        }
      ]
    }
  )
}

# Cloudfront origin access control
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac-${var.bucket_name}"
  description                       = "oac-policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Cloudfront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.objects-bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = "s3-${aws_s3_bucket.objects-bucket.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-${aws_s3_bucket.objects-bucket.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# upload objects in S3
resource "aws_s3_object" "upload-objects" {
  for_each     = fileset("${path.module}/www/", "*")
  bucket       = aws_s3_bucket.objects-bucket.id
  key          = each.value
  source       = "${path.module}/www/${each.value}"
  etag         = filemd5("${path.module}/www/${each.value}")
  content_type = "text/html"
}

# website configutation
resource "aws_s3_bucket_website_configuration" "static-website" {
  bucket = aws_s3_bucket.objects-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
