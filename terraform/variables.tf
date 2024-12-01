variable "github_token" {
  description = "GitHub token with repo permissions"
  type        = string
}

variable "organization" {
  description = "GitHub organization to create repositories in"
  type        = string
}

variable "repos_json" {
  description = "Path to the JSON file containing repository information"
  type        = string
}

variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
}

variable "github_app_pkey" {
  description = "GitHub App Private Key"
  type        = string
}

variable "organization" {
  description = "GitHub organization to create repositories in"
  type        = string
}

variable "repos_json" {
  description = "Path to the JSON file containing repository information"
  type        = string
  default     = "terraform/repos.json"
}
