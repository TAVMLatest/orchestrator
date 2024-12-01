locals {
  # Concat with repos.json name
  commit_email = "terraform@orchestrator.avmupgrades"
}
resource "github_repository_file" "ga_workflow_main_updates" {
  repository          = "terraform-azurerm-avm-res-documentdb-databaseaccount"
  branch              = "main"  # or whichever branch you want to add the file to
  file                = "../files/avm_upgrades_to_main.yml"
  content             = "This is a new GitHub Action workflow for AVPUpgrades to main branch"
  commit_message      = "[AVMUpgrades] Add GitHub Action workflow to update main branch"
  commit_author       = "Terraform"
  commit_email        = local.commit_email
  overwrite_on_create = true
}