
provider "azurerm" {
  # Configuration options

  features{}
subscription_id = "yoursubscriptionid" # Replace with your Azure subscription ID
}

resource "azurerm_resource_group" "lucky" {
name = var.resource_group_name
location = var.location
}

resource "azurerm_virtual_network" "Lucky" {
    name                = var.vnet_name
    resource_group_name = azurerm_resource_group.lucky.name
    location            = azurerm_resource_group.lucky.location
    address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "testsubnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.lucky.name
  virtual_network_name = azurerm_virtual_network.Lucky.name
  address_prefixes     = var.subnet_address_prefix
}

resource "azurerm_public_ip" "luckyyy" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.lucky.location
  resource_group_name = azurerm_resource_group.lucky.name
  allocation_method   = "Static"
  sku                 = "Standard"
  }

resource "azurerm_network_security_group" "nsg1" {
name = var.nsg_name
location            = azurerm_resource_group.lucky.location
resource_group_name = azurerm_resource_group.lucky.name
security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "Nic11" {
  name                = var.nic_name
  location            = azurerm_resource_group.lucky.location
  resource_group_name = azurerm_resource_group.lucky.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.testsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.luckyyy.id
  }
}

resource "azurerm_network_interface_security_group_association" "assoc" {
    network_interface_id      = azurerm_network_interface.Nic11.id
    network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_linux_virtual_machine" "Luck1234" {
  resource_group_name = azurerm_resource_group.lucky.name
  name                = var.vm_name
  location           = azurerm_resource_group.lucky.location
  
  size               = var.vm_size
    admin_username     = var.admin_username
    admin_password     = var.password
    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    network_interface_ids = [azurerm_network_interface.Nic11.id]
    disable_password_authentication = false
    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }
    }

    resource "azurerm_storage_account" "lucky_storage" {
  name                     = var.storage_account_name
    resource_group_name      = azurerm_resource_group.lucky.name
    location                 = azurerm_resource_group.lucky.location
    account_tier            = "Standard"
    account_replication_type = "LRS"
    access_tier             = "Hot"
    }