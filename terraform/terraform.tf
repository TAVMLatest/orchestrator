terraform {
  required_version = ">= 1.10.0"

  backend "azurerm" {
    resource_group_name   = "rg-gitopsiq-terraform-state"
    storage_account_name  = "sagitopsiqtfstate"
    container_name        = "tavmlatest"
    key                   = "github-app-manager.tfstate"
    use_azuread_auth      = true
  }
}

provider "github" {
  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
    pem_file        = file(var.github_app_private_key)
  }
}

