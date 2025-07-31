variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-arc-aks-test"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-arc-test"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29.7"
}

variable "node_count" {
  description = "Initial number of nodes"
  type        = number
  default     = 3
}

variable "min_node_count" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 5
}

variable "node_size" {
  description = "Size of the AKS nodes"
  type        = string
  default     = "Standard_D4s_v3"
}
