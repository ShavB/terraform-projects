variable "region" {
  description = "resources default region"
  type        = string
}

variable "tags" {
  description = "Common tag for all resources"
  type        = map(string)
  default = {
    Project     = "ec2-with-vpc-nginx"
    Environment = "practice"
    Managed_By  = "Terraform"
  }
}

variable "vpc-cidr" {
  description = "cidr range for VPC"
  type        = string
}

variable "subnet-cidr" {
  description = "cidr range for VPC"
  type        = string
}

variable "key-pair-name" {
  description = "aws key pair for ec2"
  type        = string
}
