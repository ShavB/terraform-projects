output "s3_website_url" {
  value = aws_s3_bucket.objects-folder.website_endpoint
}
