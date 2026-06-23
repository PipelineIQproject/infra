# Root-only setup:
# 1. Keep this backend block commented for the first terraform apply.
# 2. The root config creates the state storage account in tfstate.tf.
# 3. After apply, uncomment this block with the created storage account values.
# 4. Run terraform init -migrate-state to move local state to Azure Storage.
#
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-pipelineiq-tfstate"
#     storage_account_name = "stpipelineiqtfxxxxxx"
#     container_name       = "tfstate"
#     key                  = "pipelineiq-prod.tfstate"
#   }
# }
