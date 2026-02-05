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
          "Sid" : "Statement1",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : [
            "s3:GetObject"
          ],
          "Resource" : "${aws_s3_bucket.website-bucket.arn}/*"
        }
      ]
    }
  )
}

resource "aws_s3_object" "objects-files" {
  for_each = fileset("${path.module}/www/", "*")
  bucket   = aws_s3_bucket.website-bucket.id
  key      = each.value
  source   = "${path.module}/www/${each.value}"
  content_type = "text/html"
  etag = filemd5("${path.module}/www/${each.value}")
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
