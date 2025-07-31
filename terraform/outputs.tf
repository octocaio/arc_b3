output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.arc_rg.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.arc_aks.name
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.arc_aks.id
}

output "aks_kubeconfig" {
  description = "Kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.arc_aks.kube_config_raw
  sensitive   = true
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.arc_aks.fqdn
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.arc_logs.id
}

output "cluster_identity_principal_id" {
  description = "Principal ID of the AKS cluster managed identity"
  value       = azurerm_kubernetes_cluster.arc_aks.identity[0].principal_id
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet managed identity"
  value       = azurerm_kubernetes_cluster.arc_aks.kubelet_identity[0].object_id
}

# Azure Container Registry outputs
output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.arc_acr.name
}

output "acr_login_server" {
  description = "Login server for the Azure Container Registry"
  value       = azurerm_container_registry.arc_acr.login_server
}

output "acr_admin_username" {
  description = "Admin username for the Azure Container Registry"
  value       = azurerm_container_registry.arc_acr.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Admin password for the Azure Container Registry"
  value       = azurerm_container_registry.arc_acr.admin_password
  sensitive   = true
}
