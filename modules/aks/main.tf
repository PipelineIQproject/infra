resource "azurerm_kubernetes_cluster" "main" {
  name                      = var.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  dns_prefix                = var.name
  kubernetes_version        = var.kubernetes_version
  private_cluster_enabled   = true
  private_dns_zone_id       = "System"
  oidc_issuer_enabled       = true
  sku_tier                  = "Standard"
  workload_identity_enabled = true
  tags                      = var.tags

  default_node_pool {
    name                 = "system"
    vm_size              = var.node_vm_size
    node_count           = var.node_count
    vnet_subnet_id       = var.subnet_id
    orchestrator_version = var.kubernetes_version
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  ingress_application_gateway {
    gateway_id = var.app_gateway_id
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    service_cidr      = "10.30.0.0/16"
    dns_service_ip    = "10.30.0.10"
    outbound_type     = "userAssignedNATGateway"
    load_balancer_sku = "standard"
  }
}
