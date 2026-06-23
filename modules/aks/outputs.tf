output "id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "kubelet_object_id" {
  value = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

output "kubelet_client_id" {
  value = azurerm_kubernetes_cluster.main.kubelet_identity[0].client_id
}

output "principal_id" {
  value = azurerm_kubernetes_cluster.main.identity[0].principal_id
}

output "agic_object_id" {
  value = azurerm_kubernetes_cluster.main.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
