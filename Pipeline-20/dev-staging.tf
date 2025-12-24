terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

provider "azurerm" {
  features {}
    subscription_id = "your Subscription ID"
}

#variable for location for both dev and staging
variable "location" {       
  type    = string
  default = "Central India"
}

variable "project_name" {
  type    = string
  default = "luckydotnet"
}

# App Service names must be globally unique.
# Keep this suffix FIXED for the project (example: "p01", "team1", "demo01").
variable "unique_suffix" {
  type        = string
  description = "Unique suffix used in app service names"
  default     = "p01"
}

variable "dotnet_version" {
  type    = string
  default = "v8.0"
}


# DEV Resources (environment)
resource "azurerm_resource_group" "rg_dev" {
  name     = "rg-${var.project_name}-dev"
  location = var.location
}

resource "azurerm_service_plan" "asp_dev" {
  name                = "asp-${var.project_name}-dev"
  resource_group_name = azurerm_resource_group.rg_dev.name
  location            = var.location
  os_type             = "Windows"
  sku_name            = "B1"
}

resource "azurerm_windows_web_app" "app_dev" {
  name                = "app-${var.project_name}-dev-${var.unique_suffix}"
  resource_group_name = azurerm_resource_group.rg_dev.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.asp_dev.id

  site_config {
    always_on = true
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = var.dotnet_version
    }
  }

  app_settings = {
    ENV = "DEV"
  }
}


# STAGING Resources (environment)
resource "azurerm_resource_group" "rg_staging" {
  name     = "rg-${var.project_name}-staging"
  location = var.location
}

resource "azurerm_service_plan" "asp_staging" {
  name                = "asp-${var.project_name}-staging"
  resource_group_name = azurerm_resource_group.rg_staging.name
  location            = var.location
  os_type             = "Windows"
  sku_name            = "B1"
}

resource "azurerm_windows_web_app" "app_staging" {
  name                = "app-${var.project_name}-staging-${var.unique_suffix}"
  resource_group_name = azurerm_resource_group.rg_staging.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.asp_staging.id

  site_config {
    always_on = true
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = var.dotnet_version
    }
  }

  app_settings = {
    ENV = "STAGING"
  }
}
