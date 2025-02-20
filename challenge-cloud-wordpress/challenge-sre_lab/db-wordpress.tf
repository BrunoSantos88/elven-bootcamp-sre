resource "azurerm_virtual_network" "vnet-elvendb" {
  name                = "db-wordpress-elven"
  location            = azurerm_resource_group.rg3.location
  resource_group_name = azurerm_resource_group.rg3.name
  address_space       = ["192.16.0.0/16"]
}

resource "azurerm_subnet" "subnetdb" {
  name                 = "db-wordpress"
  resource_group_name  = azurerm_resource_group.rg3.name
  virtual_network_name = azurerm_virtual_network.vnet-elvendb.name
  address_prefixes     = ["192.16.1.0/24"]
}

resource "azurerm_public_ip" "db-nat_public_ip" {
  name                    = "dbNatPublicIP"
  location                = azurerm_resource_group.rg3.location
  resource_group_name     = azurerm_resource_group.rg3.name
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 4
}

resource "azurerm_nat_gateway" "db_natgatway" {
  name                    = "nat-gateway"
  location                = azurerm_resource_group.rg3.location
  resource_group_name     = azurerm_resource_group.rg3.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_subnet_nat_gateway_association" "db_subnet_nat_assoc" {
  subnet_id      = azurerm_subnet.subnetdb.id
  nat_gateway_id = azurerm_nat_gateway.db_natgatway.id
}

output "db_nat_gateway_id" {
  value = azurerm_nat_gateway.db_natgatway.id
}