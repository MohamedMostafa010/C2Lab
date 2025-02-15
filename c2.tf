terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "809d7da5-98b1-4d3c-9e02-e6440574c68b" # Must change: Replace with your Azure subscription ID
}

# Virtual Network for C2
resource "azurerm_virtual_network" "c2_vnet" {
  name                = "c2-vnet"
  location            = "West US" # Can change: Modify location as needed
  resource_group_name = "testingcncbotnet" # Must change: Replace with your resource group name
  address_space       = ["10.1.0.0/16"] # Can change: Modify IP range if needed
}

# Subnet for C2
resource "azurerm_subnet" "c2_subnet" {
  name                 = "c2-subnet"
  resource_group_name  = azurerm_virtual_network.c2_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.c2_vnet.name
  address_prefixes     = ["10.1.1.0/24"] # Can change: Modify subnet range if needed
}

# Public IP for C2
resource "azurerm_public_ip" "c2_public_ip" {
  name                = "c2-public-ip"
  location            = "West US"
  resource_group_name = "testingcncbotnet" # Must change: Replace with your resource group name
  allocation_method   = "Static"
}

# NSG for C2 (Allow SSH & HTTPS)
resource "azurerm_network_security_group" "c2_nsg" {
  name                = "c2-nsg"
  location            = "West US" # Can change: Modify location as needed
  resource_group_name = "testingcncbotnet" # Must change: Replace with your resource group name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAnyHTTPInbound"
    priority                   = 1012
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAnyCustom8000Inbound"
    priority                   = 1022
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAnyCustom7777Inbound"
    priority                   = 1032
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7777"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface for C2
resource "azurerm_network_interface" "c2_nic" {
  name                = "c2-nic"
  location            = "West US" # Can change: Modify location as needed
  resource_group_name = "testingcncbotnet" # Must change: Replace with your resource group name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.c2_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.c2_public_ip.id
  }
}

# Associate NSG with C2 NIC
resource "azurerm_network_interface_security_group_association" "c2_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.c2_nic.id
  network_security_group_id = azurerm_network_security_group.c2_nsg.id
}

# C2 Virtual Machine
resource "azurerm_virtual_machine" "c2_vm" {
  name                  = "c2-vm"
  location              = "West US" # Can change: Modify location as needed
  resource_group_name   = "testingcncbotnet" # Must change: Replace with your resource group name
  network_interface_ids = [azurerm_network_interface.c2_nic.id]
  vm_size               = "Standard_D2s_v3" # Can change: Modify Size as needed

  storage_os_disk {
    name              = "c2-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = 30
  }

  storage_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_profile {
    computer_name  = "c2-vm"
    admin_username = "azureuser" # Can change: Modify username as needed
    admin_password = "YourStrongPassword123!" # Can change: password location as needed
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
