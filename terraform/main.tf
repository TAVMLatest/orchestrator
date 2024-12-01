provider "github" {
  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
    pem_file        = file(var.github_app_pkey)
  }
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

resource "null_resource" "generate_repos_json" {
  provisioner "local-exec" {
    command = "./scripts/populate_repos_json.sh"
  }
}

data "local_file" "repos" {
  filename = var.repos_json
  depends_on = [null_resource.generate_repos_json]
}

locals {
  repos = jsondecode(data.local_file.repos.content)
}

resource "github_repository" "forks" {
  for_each = local.repos

  name        = each.value.name
  description = each.value.description
  private     = each.value.private

  source {
    owner      = "Azure"
    repository = each.value.source_repo
  }
}
