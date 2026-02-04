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
// Use for_each to upload multiple files 
resource "aws_s3_object" "object" {
  for_each = fileset("${path.module}/www/", "*")

  bucket = aws_s3_bucket.objects-folder.id
  key    = each.value
  source = "${path.module}/www/${each.value}"
  etag   = filemd5("${path.module}/www/${each.value}")
}
