terraform {
    backend "azurerm" {
        resource_group_name  = "tfstate-rg" # Replace with your resource group name
        storage_account_name = "tfstatestorage23315" # replace with your storage account nam
        container_name       = "tfstate" # replace with your container name
        key                  = "terraform.tfstate"# This is the name of the state file in the container
    }
}