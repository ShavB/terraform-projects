/*
  1. Create s3 bucket
  2. Disable block public access
  3. create bucket policy
  4. upload multiple files
  5. Setup website configuration
*/

resource "aws_s3_bucket" "website-bucket" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "public-access" {
  bucket = aws_s3_bucket.website-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket     = aws_s3_bucket.website-bucket.id
  depends_on = [aws_s3_bucket_public_access_block.public-access]
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowCloudFrontToAccess",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cloudfront.amazonaws.com",
          }
          "Action" : [
            "s3:GetObject"
          ],
          "Resource" : "${aws_s3_bucket.website-bucket.arn}/*",
          "Condition" : {
            "ArnEquals" : {
              "aws:SourceArn" : aws_cloudfront_distribution.s3_distribution.arn
            }
          }
        }
      ]
    }
  )
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac-${var.bucket_name}"
  description                       = "S3 - Cloudfront origin access policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website-bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = "S3-${aws_s3_bucket.website-bucket.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Hosted a static website"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website-bucket.id}"

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
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_s3_object" "objects-files" {
  for_each     = fileset("${path.module}/www/", "*")
  bucket       = aws_s3_bucket.website-bucket.id
  key          = each.value
  source       = "${path.module}/www/${each.value}"
  content_type = "text/html"
  etag         = filemd5("${path.module}/www/${each.value}")
}

resource "aws_s3_bucket_website_configuration" "website-config" {
  bucket = aws_s3_bucket.website-bucket.id
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
