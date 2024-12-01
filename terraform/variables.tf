variable "organization" {
  description = "GitHub organization to create repositories in"
  type        = string
}

variable "github_app_jwt_token" {
  description = "GitHub App JWT token with repo permissions"
  type        = string
}
