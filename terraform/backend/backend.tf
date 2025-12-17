terraform {
  backend "s3" {
    bucket         = "autonomous-aws-security-tfstate"
    key            = "demo/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
