# https://www.terraform.io/docs/providers/index.html

# Configure the Terraform Provider with Azure Storage Account
# more info : https://www.terraform.io/docs/backends/types/azurerm.html
terraform {
  backend "azurerm" {
    resource_group_name  = "<RESOURCEGROUP>"
    storage_account_name = "<ACCOUNTNAME>"
    container_name       = "<CONTAINERNAME>"
    key                  = "<PROJECTNAME>.tfstate"
  }
  required_providers {
    azurerm = {
      # source  = "hashicorp/azurerm"
      version = "~> 2.24.0"
    }
    local = {
      # source  = "hashicorp/local"
      version = "~> 1.4.0"
    }
    template = {
      # source  = "hashicorp/template"
      version = "~> 2.1.2"
    }
    time = {
      # source  = "hashicorp/time"
      version = "~> 0.5.0"
    }
    random = {
      # source  = "hashicorp/random"
      version = "~> 2.3.0"
    }
  }
}

# Configure the Azure Provider
# more info : https://registry.terraform.io/providers/hashicorp/azurerm/latest
provider "azurerm" {
  features {}
}

provider "local" {
}

provider "template" {
}

provider "time" {
}

provider "random" {
}
