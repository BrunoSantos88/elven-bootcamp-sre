resource "azurerm_resource_group" "rg1" {
  name     = "appserver1"
  location = "westus2"
}


resource "azurerm_resource_group" "rg2" {
  name     = "appserver2"
  location = "brazilsouth"
}


resource "azurerm_resource_group" "rg3" {
  name     = "bancoserver"
  location = "East US 2"
}