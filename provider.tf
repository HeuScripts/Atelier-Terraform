# https://www.terraform.io/docs/providers/index.html

subscription_id = "<SUBSCRIPTIONID>"
tenant_id       = "<TENANTID>"

## Execute in your shell (this will last the session):
# export ARM_CLIENT_ID="<APPID>"
# export ARM_CLIENT_SECRET="<PASSWORD>"
# export ARM_SUBSCRIPTION_ID="<SUBSCRIPTIONID>"
# export ARM_TENANT_ID="<TENANTID>"
## If you need to keep working with these, put them into your ~/.bashrc (just copy these lines)


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
      source = "hashicorp/azurerm"
    }
  }
}

# Configure the Azure Provider
# more info : https://registry.terraform.io/providers/hashicorp/azurerm/latest
provider "azurerm" {
  features {}
}
