 # PipelineIQ Azure Infrastructure

Terraform for the PipelineIQ Azure platform.

This repository creates the Azure infrastructure only. Application deployment stays in the Kubernetes/Helm repository.

## Architecture

Terraform creates:

- Terraform state storage resource group, storage account, and blob container
- Main resource group
- Two VNets:
  - Application VNet
  - Database VNet    
- VNet peering between application and database VNets
- AKS private cluster 
- Azure Application Gateway with AGIC add-on
- Azure Container Registry
- Azure Key Vault with private endpoint
- Azure PostgreSQL Flexible Server in the database VNet
- Public Azure Service Bus with queues
- SSH jumpbox VM with public IP
- NAT Gateway for private outbound access
- Microsoft Entra app registration and client secret
- Role assignments for AKS to pull from ACR and read Key Vault secrets

## Network Layout

```text
vnet-app
|-- snet-aks
|-- snet-appgw
|-- snet-private-endpoints
`-- snet-jumpbox

vnet-data
`-- snet-postgres
```

The VNets are peered both ways. PostgreSQL private DNS is linked to both VNets so AKS can resolve the private database hostname.

## Root-Only Terraform Flow

This setup does not use a separate bootstrap folder.

For the first run, keep `backend.tf` commented. Terraform will use local state for the first apply and create the Azure Storage Account that can later hold remote state.

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update at least:

```hcl
admin_email                  = "your-email@example.com"
postgres_admin_password      = "strong-password"
app_domain                   = "www.pipelinesolutions.xyz"
tfstate_storage_account_name = null
```

By default, the Terraform state storage account name is generated with a random
suffix so it is valid and globally unique. If you set
`tfstate_storage_account_name` yourself, it must be 3-24 lowercase letters or
numbers and globally unique across Azure.

The default AKS system pool is one `Standard_D2s_v5` node so the first apply fits
subscriptions with only 2 available regional vCPUs. Increase `aks_node_count` or
`aks_node_vm_size` after Azure quota is available.

Leave `key_vault_name` as `null` unless you already own a globally unique vault
name. Terraform will derive a suffix-based vault name such as
`pipelineiqproda814kv`.

ACR, PostgreSQL, Service Bus, and the Terraform state storage account include a
generated suffix so first apply avoids global name collisions.

Then run:

```bash
terraform init -reconfigure
terraform plan
terraform apply
```

After the first apply, Terraform outputs:

```text
tfstate_resource_group_name
tfstate_storage_account_name
tfstate_container_name
```

If you want remote state, uncomment the backend block in `backend.tf`, fill those values, and run:

```bash
terraform init -migrate-state
```

## Microsoft Entra App Registration

Terraform creates the Microsoft Entra app registration, service principal, client secret, and stores the generated secret in Key Vault as:

```text
entra-client-secret
```

After Terraform apply, use these outputs:

```bash
terraform output entra_tenant_id
terraform output entra_client_id
terraform output entra_redirect_uri
```

The redirect URI is generated from `app_domain`:

```text
https://<app_domain>/api/auth/entra/callback
```

For example:

```text
https://www.pipelinesolutions.xyz/api/auth/entra/callback
```

If this fails with an Entra permission error, your new account needs permission to create app registrations.

## Important Secret Handling

Terraform creates Azure Key Vault and writes only the generated Entra client secret into it.

Add these manually in Azure Portal or Azure CLI:

```text
database-url
github-client-id
github-client-secret
github-webhook-secret
jwt-secret
token-encryption-key
azure-openai-api-key
gemini-api-key
servicebus-connection-string
smtp-host
smtp-user
smtp-password
smtp-from
```

If Terraform creates Service Bus, get the connection string with:

```bash
terraform output -raw servicebus_connection_string
```

Then store them in Key Vault:

```bash
az keyvault secret set \
  --vault-name <key-vault-name> \
  --name servicebus-connection-string \
  --value "<servicebus-connection-string>"
```

## After Terraform

Get AKS credentials from the jumpbox VM because the AKS cluster is private:

```bash
az aks get-credentials \
  --resource-group <resource-group-name> \
  --name <aks-name>
```

Then deploy the Kubernetes/Helm repo from the jumpbox:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/keyvault-secretprovider.yaml
kubectl apply -f k8s/keyvault-sync.yaml
kubectl apply -f k8s/apps.yaml
kubectl apply -f k8s/agic/ingress.yaml
```

## Notes

- Keep Key Vault public network access enabled during setup if you want to add secrets from Portal/Cloud Shell.
- Disable Key Vault public access later only after private access through jumpbox is confirmed.
- The PostgreSQL admin password is stored in Terraform state because Azure requires it during server creation.
- SSH to the jumpbox public IP, then use it for `kubectl`, `helm`, and private DNS/database checks.
