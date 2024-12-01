terraform {
  required_version = ">= 1.10.0"

  backend "azurerm" {
    resource_group_name   = "rg-gitopsiq-terraform-state"
    storage_account_name  = "sagitopsiqtfstate"
    container_name        = "avmupgrades"
    key                   = "github-app-manager.tfstate"
    use_azuread_auth      = true
  }
}

# Authenticate with GitHub using a GitHub App and environment variables
provider "github" {
}

