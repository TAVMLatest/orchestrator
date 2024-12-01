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
