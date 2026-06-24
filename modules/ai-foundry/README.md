# AI Foundry Module

This module defines the Azure AI Services account used as the backing resource for Azure AI Foundry.

It is intentionally kept as a standalone module. It is not called from the root Terraform configuration yet, so adding this folder does not create or change any Azure resources.

## Future Usage

```hcl
module "ai_foundry" {
  source = "./modules/ai-foundry"

  name                = "pipelineiq-prod-ai"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  custom_subdomain_name = "pipelineiq-prod-ai"

  tags = local.merged_tags
}
```

Only add the module call in root `main.tf` when AI Foundry deployment is ready to be included in the pipeline.
