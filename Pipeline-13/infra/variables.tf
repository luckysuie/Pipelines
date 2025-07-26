variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "The name of the resource group where resources will be created."
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network to create."
  type        = string
  
}
variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
}

variable "subnet_name" {
  description = "The name of the subnet to create."
  type        = string
}

variable "subnet_address_prefix" {
  description = "The address prefix for the subnet."
  type        = list(string)
} 

variable "public_ip_name" {
  description = "The name of the public IP address to create."
  type        = string
}

variable "nsg_name" {
  description = "The name of the network security group to create."
  type        = string
}

variable "nic_name" {
  description = "The name of the network interface to create."
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine to create."
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine."
  type        = string
}

variable "admin_username" {
  description = "The administrator username for the virtual machine."
  type        = string
}

variable "password" {
  description = "The administrator password for the virtual machine."
  type        = string
  sensitive   = true
}

variable "storage_account_name" {
  description = "The name of the storage account to create."
  type        = string
}