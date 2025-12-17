variable "github_org" {
  description = "GitHub organization or username that owns the repo"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the role"
  type        = string
  default     = "main"
}

variable "tags" {
  description = "Tags applied to IAM resources"
  type        = map(string)
}

variable "github_oidc_thumbprint" {
  description = "SHA1 thumbprint for GitHub Actions OIDC provider TLS cert chain"
  type        = string
}

variable "project_tag_key" {
  description = "Tag key used to scope Terraform permissions"
  type        = string
  default     = "Project"
}

variable "project_tag_value" {
  description = "Tag value used to scope Terraform permissions"
  type        = string
}
