variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
}

variable "github_app_private_key" {
  description = "GitHub App Private Key"
  type        = string
}

variable "organization" {
  description = "GitHub organization to create repositories in"
  type        = string
}

variable "github_app_jwt_token" {
  description = "GitHub App JWT token with repo permissions"
  type        = string
}
