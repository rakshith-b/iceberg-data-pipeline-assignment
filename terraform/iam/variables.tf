variable "region" {
  type    = string
  default = "us-west-2"
}

variable "prefix" {
  type    = string
  default = "iceberg"
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket name for storing Iceberg tables"
}

variable "eks_oidc_provider_url" {
  type        = string
  description = "OIDC issuer URL from EKS cluster"
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "OIDC provider ARN from EKS cluster"
}
