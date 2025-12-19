provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"

  cluster_name = "cis-secure-eks-demo"

  vpc_cidr = "10.0.0.0/16"

  private_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  tags = {
    Environment = var.environment
    Project     = "autonomous-aws-security-platform"
    Owner       = "security"
  }
}

module "iam" {
  source = "../../modules/iam"

  github_org    = "SecureCloudOps"
  github_repo   = "autonomous-aws-security-platform"
  github_branch = "main"

  github_oidc_thumbprint = var.github_oidc_thumbprint

  project_tag_value = "autonomous-aws-security-platform"

  tags = {
    Environment = var.environment
    Project     = "autonomous-aws-security-platform"
    Owner       = "security"
  }
}
