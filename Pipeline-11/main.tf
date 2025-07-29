provider "azurerm" {
  features {}
    subscription_id = "your subscription"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "lucky"
  location = "Canada Central"
}

# App Service Plan (Linux)
resource "azurerm_service_plan" "main" {
  name                = "lucky-appserviceplan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "B1"  # Basic Tier
}

# Linux Web App with Node.js
resource "azurerm_linux_web_app" "main" {
  name                = "luckywebapp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    application_stack {
      node_version = "22-lts"  # Use "20-lts"
    }
  }

  https_only = true
}

# Cosmos DB (MongoDB API)
resource "azurerm_cosmosdb_account" "main" {
  name                = "lucky-server"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableMongo"
  }
}

resource "azurerm_cosmosdb_mongo_database" "main" {
  name                = "lucky-database"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
}

# Azure Cache for Redis
resource "azurerm_redis_cache" "main" {
  name                = "luckyredis"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
}
