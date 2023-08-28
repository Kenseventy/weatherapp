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

# Create a storage account for the Function App
resource "azurerm_storage_account" "funcstorage" {
  name                     = "weathertracker"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create an App Service Plan for the Function App
resource "azurerm_app_service_plan" "funcplan" {
  name                = "EastUSLinuxDynamicPlan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

# Create the Function App
resource "azurerm_function_app" "funcapp" {
  name                       = "weathertrackerfunction"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.funcplan.id
  storage_account_name       = azurerm_storage_account.funcstorage.name
  storage_account_access_key = azurerm_storage_account.funcstorage.primary_access_key
  version                    = "~3" # Assuming you're targeting Functions v3. Adjust as needed.

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
  }
}

# Output for the Function App URL
output "function_app_default_hostname" {
  value = azurerm_function_app.funcapp.default_hostname
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