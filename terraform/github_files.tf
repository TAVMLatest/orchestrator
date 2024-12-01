locals {
  files_path = "${path.module}/files"

  # Get all files recursively in the files directory
  all_files = fileset(local.files_path, "**/*")

  # Create a map of file paths to their content, removing the "files/" prefix
  file_map = {
    for file in local.all_files :
    trimprefix(file, "files/") => filebase64("${local.files_path}/${file}")
  }

  commit_email = "terraform@updatedfiles.devops"
}

resource "github_repository_file" "ga_workflow_main_updates" {
  for_each            = local.file_map
  repository          = "terraform-azurerm-avm-res-documentdb-databaseaccount"
  branch              = "main" # or whichever branch you want to add the file to
  file                = each.key
  content             = base64decode(each.value)
  commit_message      = "[AVMUpgrades] Add GitHub Action workflow to update main branch"
  commit_author       = "Terraform"
  commit_email        = local.commit_email
  overwrite_on_create = true
}
