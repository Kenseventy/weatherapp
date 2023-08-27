provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "weathertracker-rg"
  location = "East US" # Choose your preferred region
}

resource "azurerm_container_registry" "acr" {
  name                = "weatheracr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}




resource "azurerm_container_group" "aci" {
  name                = "weathercontainer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  container {
    name   = "weathercontainer"
    image  = "${azurerm_container_registry.acr.login_server}/weather_app:v2"
    cpu    = "1.0"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

  }

  image_registry_credential {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password = azurerm_container_registry.acr.admin_password
  }

  tags = {
    environment = "az-204"
  }
}


output "acr_admin_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  value = azurerm_container_registry.acr.admin_password
  sensitive = true
}

output "container_public_ip" {
  value = azurerm_container_group.aci.ip_address
}