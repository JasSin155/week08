terraform {
    required_version = ">= 1.7.0"

    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 4.0"
        }
    }

    # ============================================================================
    # Remote state backend.
    #
    # This is the piece that makes "terraform apply" safe to run automatically
    # from GitHub Actions on every push. Every CI job runs on a brand new,
    # stateless runner, so if state stayed on disk the way it did in Weeks 6-9
    # (a local terraform.tfstate file), every single CI run would start from
    # zero knowledge of what already exists in Azure. The second run would try
    # to create a resource group that already exists and fail, not silently
    # apply an update.
    #
    # Storing state in an Azure Storage blob container instead means every CI
    # run reads the same state file the previous run wrote, so `terraform plan`
    # correctly shows "no changes" on a rerun instead of trying to recreate
    # everything. use_azuread_auth = true means the pipeline's existing service
    # principal (the same AZURE_CREDENTIALS already used by azure/login)
    # authenticates to the state storage account directly, so no separate
    # storage account key has to be generated or stored as a second secret.
    #
    # The storage account and container named below cannot be created by this
    # same Terraform configuration, a backend has to already exist before
    # `terraform init` can use it. See the runbook for the one-time, by-hand
    # bootstrap command.
    # ============================================================================
    backend "azurerm" {
        resource_group_name  = "koalatech-tfstate-rg"
        storage_account_name = "jas220tfstatew10d"
        container_name       = "tfstate"
        key                  = "week10-2d.tfstate"
        use_azuread_auth     = true
    }
}

provider "azurerm" {
    features {}
}

data "azurerm_client_config" "current" {}
