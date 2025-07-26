output "resource_group_name" {
  value = azurerm_resource_group.lucky.name
}
output "location" {
  value = azurerm_resource_group.lucky.location
}
output "vnet_name" {
  value = azurerm_virtual_network.Lucky.name
}

output "Address_Space" {
  value = azurerm_virtual_network.Lucky.address_space
}

output "subnet_name" {
  value = azurerm_subnet.testsubnet.name
} 
output "subnet_address_prefix" {
  value = azurerm_subnet.testsubnet.address_prefixes
}

output "public_ip_name" {
  value = azurerm_public_ip.luckyyy.name
}

output "public_ip_address" {
  value = azurerm_public_ip.luckyyy.ip_address
}
output "nsg_name" {
  value = azurerm_network_security_group.nsg1.name
}
output "nic_name" {
  value = azurerm_network_interface.Nic11.name
}   

output "vm_name" {
  value = azurerm_linux_virtual_machine.Luck1234.name
}

output "storage_account_name" {
  value = azurerm_storage_account.lucky_storage.name
}