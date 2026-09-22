#Specify your environments (Azure,Aws,etc)
#
# You can create provider aliases, to specify which subscription/cloud to use
#provider "azurerm" {
#    alias = "dev"
#    features {}
#}
# Will make provider =azurerm.dev 
# Work as an attribute inside a resource block.
#
#
terraform {
  required_version = "~> 1.16.0"
  cloud {
    organization = "LearnTerraform1593483"

    workspaces {
      name = "Learn-Terraform-Udemy"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>5.0"
    }
  }
}
provider "azurerm" {
  features {}
}
