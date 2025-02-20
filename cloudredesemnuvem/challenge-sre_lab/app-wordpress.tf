resource "azurerm_virtual_network" "vnet-elven" {
  name                = "app-wordpress-elven"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = ["172.0.0.0/16"]
}

resource "azurerm_subnet" "subnet1" {
  name                 = "app-wordpress-one"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet-elven.name
  address_prefixes     = ["172.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "app-wordpress-two"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet-elven.name
  address_prefixes     = ["172.0.2.0/24"]
}

resource "azurerm_public_ip" "nat_public_ip" {
  name                    = "myNatPublicIP"
  location                = azurerm_resource_group.rg1.location
  resource_group_name     = azurerm_resource_group.rg1.name
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 4
}

resource "azurerm_nat_gateway" "mynatgatway" {
  name                    = "nat-gateway"
  location                = azurerm_resource_group.rg1.location
  resource_group_name     = azurerm_resource_group.rg1.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_subnet_nat_gateway_association" "subnet_nat_assoc" {
  subnet_id      = azurerm_subnet.subnet1.id
  nat_gateway_id = azurerm_nat_gateway.mynatgatway.id
}

output "nat_gateway_id" {
  value = azurerm_nat_gateway.mynatgatway.id
}