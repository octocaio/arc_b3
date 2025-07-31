# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "rg-arc-aks-test"
    storage_account_name = "arcb3tfstate90183"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "arc_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "test"
    Project     = "arc-aks-optimization"
    Owner       = "octocaio"
  }
}

# Create Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "arc_logs" {
  name                = "${var.cluster_name}-logs"
  location            = azurerm_resource_group.arc_rg.location
  resource_group_name = azurerm_resource_group.arc_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "test"
    Project     = "arc-aks-optimization"
  }
}

# Create AKS cluster
resource "azurerm_kubernetes_cluster" "arc_aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.arc_rg.location
  resource_group_name = azurerm_resource_group.arc_rg.name
  dns_prefix          = "${var.cluster_name}-dns"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = "default"
    vm_size         = var.node_size
    type            = "VirtualMachineScaleSets"
    zones           = ["1", "2", "3"]
    
    # Enable auto-scaling
    enable_auto_scaling = true
    node_count         = var.node_count
    min_count          = var.min_node_count
    max_count          = var.max_node_count

    # Optimize for container workloads
    linux_os_config {
      sysctl_config {
        vm_max_map_count = 262144
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.arc_logs.id
  }

  azure_policy_enabled = true

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "azure"
  }

  # Enable monitoring and logging
  monitor_metrics {
  }

  tags = {
    Environment = "test"
    Project     = "arc-aks-optimization"
  }
}

# Create Azure Container Registry for custom runner images
resource "azurerm_container_registry" "arc_acr" {
  name                = "${replace(var.cluster_name, "-", "")}registry"
  resource_group_name = azurerm_resource_group.arc_rg.name
  location            = azurerm_resource_group.arc_rg.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    Environment = "test"
    Project     = "arc-aks-optimization"
    Purpose     = "custom-runner-images"
  }
}

# Role assignment for AKS to pull images from ACR (if needed later)
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.arc_aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                           = azurerm_container_registry.arc_acr.id
  skip_service_principal_aad_check = true
}
