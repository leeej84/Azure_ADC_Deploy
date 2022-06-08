# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.76"
    }
  }
}

#Provider and subscription
provider "azurerm" {
  alias           = "defaultsub"
  subscription_id = var.subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

#Resource group for all resource
resource "azurerm_resource_group" "rg_e2evc" {
  provider = azurerm.defaultsub
  name     = var.rg
  location = var.default_location
}

resource "azurerm_network_security_group" "nsg_e2evc" {
  name                = var.nsg_e2evc
  provider            = azurerm.defaultsub
  location            = var.default_location
  resource_group_name = azurerm_resource_group.rg_e2evc.name
}

resource "azurerm_virtual_network" "vnet_e2evc" {
  name                = var.vnet_e2evc
  provider            = azurerm.defaultsub
  location            = var.default_location
  resource_group_name = azurerm_resource_group.rg_e2evc.name
  address_space       = ["10.1.0.0/16"]
  dns_servers         = ["8.8.8.8", "8.8.4.4"]
}

resource "azurerm_subnet" "subnet1" {
  provider             = azurerm.defaultsub
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg_e2evc.name
  virtual_network_name = azurerm_virtual_network.vnet_e2evc.name
  address_prefixes     = ["10.1.1.0/24"]
}

##Common components
resource "azurerm_storage_account" "st_e2evc_storage" {
  provider                 = azurerm.defaultsub
  name                     = var.st_automation_storage
  resource_group_name      = azurerm_resource_group.rg_e2evc.name
  location                 = var.default_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#Function App service plan
resource "azurerm_service_plan" "svcplan_e2evc" {
  provider            = azurerm.defaultsub
  os_type             = "Windows"
  name                = var.asp_e2evc
  location            = var.default_location
  resource_group_name = azurerm_resource_group.rg_e2evc.name
  sku_name            = "Y1"
}

#Function App itself
resource "azurerm_windows_function_app" "funtionapp_automation" {
  provider                   = azurerm.defaultsub
  name                       = var.functionapp_e2evc
  location                   = var.default_location
  resource_group_name        = azurerm_resource_group.rg_e2evc.name
  service_plan_id            = azurerm_service_plan.svcplan_e2evc.id
  storage_account_name       = azurerm_storage_account.st_e2evc_storage.name
  storage_account_access_key = azurerm_storage_account.st_e2evc_storage.primary_access_key
  
  site_config {
    application_stack {
      powershell_core_version    = "7"
    }
    ftps_state = "AllAllowed"
  }
  identity {
    type = "SystemAssigned"
  }
  https_only = true

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE       = "0"
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.la_in_e2evc.instrumentation_key
  }
}

##Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "la_e2evc" {
  provider            = azurerm.defaultsub
  name                = var.la_e2evc
  location            = var.default_location
  resource_group_name = azurerm_resource_group.rg_e2evc.name
}

#Log Analytics Insights for Function App
resource "azurerm_application_insights" "la_in_e2evc" {
  provider            = azurerm.defaultsub
  name                = var.la_in_e2evc
  location            = var.default_location
  resource_group_name = azurerm_resource_group.rg_e2evc.name
  application_type    = "web"
}

#NOT RECOMMENDED - Make system identity of Function App a global admin - NOT RECOMMENDED
resource "azurerm_role_assignment" "permissions_assignment" {
  provider             = azurerm.defaultsub
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Owner"
  principal_id         = azurerm_windows_function_app.funtionapp_automation.identity.0.principal_id
}
