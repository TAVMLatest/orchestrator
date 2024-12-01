data "local_file" "repos" {
  filename = "${path.module}/repos.json"
}


locals {
  repos_list = jsondecode(data.local_file.repos.content)
  repos = { for repo in local.repos_list : repo.name => repo }
}

resource "null_resource" "create_forks" {
  for_each = local.repos

  provisioner "local-exec" {
    command = "../scripts/create_fork.sh ${each.value.name}"

    environment = {
      GITHUB_APP_JWT_TOKEN = var.github_app_jwt_token
    }
  }
}

