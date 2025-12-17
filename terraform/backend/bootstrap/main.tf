terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = "tfstate-${var.project}-${var.environment}"
  tags        = var.tags
}

resource "aws_kms_key" "tfstate" {
  description         = "KMS CMK for Terraform remote state and lock table"
  enable_key_rotation = true
  tags                = local.tags
}

resource "aws_kms_alias" "tfstate" {
  name          = "alias/${local.name_prefix}"
  target_key_id = aws_kms_key.tfstate.key_id
}

# Log bucket for S3 access logs
resource "aws_s3_bucket" "log_bucket" {
  bucket        = "${local.name_prefix}-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = false
  tags          = local.tags
}

resource "aws_s3_bucket_public_access_block" "log_bucket" {
  bucket                  = aws_s3_bucket.log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.tfstate.arn
    }
  }
}

#checkov:skip=CKV2_AWS_62: Terraform state bucket is not application data; event notifications not required for this demo. Audit evidence is produced via CI artifacts and CloudTrail.

# State bucket
resource "aws_s3_bucket" "state" {
  bucket        = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}"
  force_destroy = false
  tags          = local.tags
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.tfstate.arn
    }
  }
}

resource "aws_s3_bucket_logging" "state" {
  bucket        = aws_s3_bucket.state.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "s3-access-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# DynamoDB lock table (CMK + PITR)
resource "aws_dynamodb_table" "lock" {
  name         = "${local.name_prefix}-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  tags         = local.tags

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.tfstate.arn
  }

  point_in_time_recovery {
    enabled = true
  }
}

output "state_bucket_name" {
  value = aws_s3_bucket.state.bucket
}

output "lock_table_name" {
  value = aws_dynamodb_table.lock.name
}
