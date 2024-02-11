terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true
  # This is only required when the User,
  # Service Principal, or Identity running Terraform 
  # lacks the permissions to register Azure Resource Providers.
  features {}
}

resource "random_integer" "ri" {
  min = 10000
  max = 99000
}

resource "azurerm_resource_group" "rg" {
  name     = "ContactBookRG-${random_integer.ri.result}"
  location = "West Europe"
}

resource "azurerm_service_plan" "asp" {
  name                = "contact-book-service-plan-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "alwa" {
  name                = "contact-book-webapp-${random_integer.ri.result}"
  resource_group_name = azurerm_service_plan.asp.resource_group_name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      node_version = "16-lts"
    }
    always_on = false
  }
}

resource "azurerm_app_service_source_control" "github" {
  app_id                 = azurerm_linux_web_app.alwa.id
  repo_url               = "https://github.com/nakov/ContactBook"
  branch                 = "master"
  use_manual_integration = true
}