output "github_actions_role_arn" {
  description = "GitHub Actions OIDC role ARN used by CI"
  value       = module.iam.github_actions_role_arn
}
