terraform {
  backend "azurerm" {
    resource_group_name  = "rg-pipelineiq-sweden"
    storage_account_name = "stpipelineiqproda81487xy"
    container_name       = "tfstate"
    key                  = "pipelineiq.tfstate"
  }
}
