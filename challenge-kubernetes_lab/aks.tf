provider "azurerm" {
  features {}

}

variable "aks_cluster_elfo" {
  type    = string
  default = "elfo-aks-cluster"
}
resource "azurerm_kubernetes_cluster" "aks_elfo" {
  name                = var.aks_cluster_elfo
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  dns_prefix          = "aks-cluster"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_DS2_v2"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }
}