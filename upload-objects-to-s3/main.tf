/* 

  1. Create S3 bucket 
  2. Upload S3 bucket objects

*/

// Create S3 bucket
resource "aws_s3_bucket" "objects-folder" {
  bucket = var.bucket_name
  tags   = var.tags
}

// Upload object to S3 bucket
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.objects-folder.id
  key    = "index-one.txt"
  source = "${path.module}/www/index.txt"
  etag   = filemd5("${path.module}/www/index.txt")
}
