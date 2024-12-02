locals {
  files_path = "${path.module}/../files"

  # Get all files recursively in the files directory
  all_files = fileset(local.files_path, "**/*")

  # Create a map of file paths to their content, removing the "files/" prefix
  file_map = {
    for file in local.all_files :
    trimprefix(file, "files/") => filebase64("${local.files_path}/${file}")
  }

  commit_email = "terraform@avmupgrades.orchestrator"
}

resource "github_repository_file" "terraform-azurerm-avm-res-documentdb-databaseaccount" {
  for_each            = local.file_map
  repository          = "terraform-azurerm-avm-res-documentdb-databaseaccount"
  branch              = "main"
  file                = each.key
  content             = base64decode(each.value)
  commit_message      = "[AVMUpgrades] Update repository files"
  commit_author       = "Terraform"
  commit_email        = local.commit_email
  overwrite_on_create = true

  depends_on = [ null_resource.create_forks ]
}

resource "github_repository_dependabot_security_updates" "terraform-azurerm-avm-res-documentdb-databaseaccount" {
  repository  = github_repository.terraform-azurerm-avm-res-documentdb-databaseaccount.id
  enabled     = true
}
