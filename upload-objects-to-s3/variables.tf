variable "regions" {
  description = "Default region"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket store bucket name"
  type        = string
}

variable "tags" {
  description = "s3 tags"
  type        = map(string)
  default = {
    Environment = "practice"
    Name        = "s3-bucket-object-store"
  }
}
