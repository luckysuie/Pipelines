# PROD Resources (Blue-Green using Slots)
resource "azurerm_resource_group" "rg_prod" {
  name     = "rg-${var.project_name}-prod"
  location = var.location
}

resource "azurerm_service_plan" "asp_prod" {
  name                = "asp-${var.project_name}-prod"
  resource_group_name = azurerm_resource_group.rg_prod.name
  location            = var.location
  os_type             = "Windows"
  sku_name            = "S1"
}

# PROD Web App (Production slot = BLUE)
resource "azurerm_windows_web_app" "app_prod" {
  name                = "app-${var.project_name}-prod-${var.unique_suffix}"
  resource_group_name = azurerm_resource_group.rg_prod.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.asp_prod.id

  site_config {
    always_on = true
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = var.dotnet_version
    }
  }

  app_settings = {
    ENV   = "PROD"
    COLOR = "BLUE"
  }
}

# Deployment Slot (staging slot = GREEN)
resource "azurerm_windows_web_app_slot" "prod_staging_slot" {
  name           = "staging"
  app_service_id = azurerm_windows_web_app.app_prod.id

  site_config {
    always_on = true
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = var.dotnet_version
    }
  }

  app_settings = {
    ENV       = "PROD"
    COLOR     = "GREEN"
    SLOT_NAME = "staging"
  }
}
