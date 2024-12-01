data "local_file" "repos" {
  filename = "repos.json"
}

locals {
  repos = jsondecode(data.local_file.repos.content)
}

resource "null_resource" "create_forks" {
  for_each = local.repos

  provisioner "local-exec" {
    command = <<EOT
      curl -X POST -H "Authorization: Bearer ${var.github_app_jwt_token}" \
      -H "Accept: application/vnd.github.v3+json" \
      https://api.github.com/repos/Azure/${each.value.source_repo}/forks \
      -d '{"organization": "${var.organization}"}'
    EOT
  }
}

data "github_repository" "forks" {
  for_each = local.repos

  full_name = "${var.organization}/${each.value.name}"

  depends_on = [ null_resource.create_forks ]
}
