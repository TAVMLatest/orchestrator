data "local_file" "repos" {
  filename = "${path.module}/repos.json"
}


locals {
  repos_list = jsondecode(data.local_file.repos.content)
  repos = { for repo in local.repos_list : repo.name => repo }
}

resource "github_repository" "repos" {
  for_each = local.repos

  name        = each.value.name
  description = each.value.description
  visibility  = "public"
  auto_init   = true
  vulnerability_alerts = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "null_resource" "create_forks" {
  for_each = local.repos

  triggers = {
    repo_name = each.value.name
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "../scripts/create_update_forks.sh ${each.value.name}"

    environment = {
      GITHUB_APP_JWT_TOKEN = var.github_app_jwt_token
    }
  }

  depends_on = [github_repository.repos]
}

