variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "demo"
}

variable "aws_account_id" {
  description = "AWS account ID used for IAM role references"
  type        = string
}

variable "github_oidc_thumbprint" {
  description = "OIDC provider thumbprint for GitHub Actions"
  type        = string
}
