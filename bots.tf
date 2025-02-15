# Virtual Network for Bots
resource "azurerm_virtual_network" "bots_vnet" {
  name                = "bots-vnet"
  location            = "West US" # Can change: Modify location as needed
  resource_group_name = "testingcncbotnet" # Must change: Replace with your resource group name
  address_space       = ["10.2.0.0/16"] # Can change: Modify IP range if needed
}

# Subnet for Bots
resource "azurerm_subnet" "bots_subnet" {
  name                 = "bots-subnet"
  resource_group_name  = azurerm_virtual_network.bots_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.bots_vnet.name
  address_prefixes     = ["10.2.1.0/24"] # Can change: Modify subnet range if needed
}

# Public IPs for Bots
resource "azurerm_public_ip" "bots_public_ip" {
  count               = 2
  name                = "bot-public-ip-${count.index}"
  location            = "West US" # Can change: Modify location as needed
  resource_group_name = "testingcncbotnet" # Must change: Replace with your resource group name
  allocation_method   = "Static"
}

# NSG for Bots (Allow SSH)
resource "azurerm_network_security_group" "bots_nsg" {
  name                = "bots-nsg"
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
    name                       = "AllowAnyCustom8000Inbound"
    priority                   = 1012
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
    priority                   = 1022
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7777"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interfaces for Bots
resource "azurerm_network_interface" "bots_nic" {
  count               = 2
  name                = "bot-nic-${count.index}"
  location            = "West US" # Can change: Modify location as needed
  resource_group_name = "testingcncbotnet" # Must change: Replace with your resource group name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.bots_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bots_public_ip[count.index].id
  }
}

# Associate NSG with Bot NICs
resource "azurerm_network_interface_security_group_association" "bots_nsg_assoc" {
  count                      = 2
  network_interface_id      = azurerm_network_interface.bots_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.bots_nsg.id
}

# Bot Virtual Machines
resource "azurerm_virtual_machine" "bots_vm" {
  count                 = 2
  name                  = "bot-vm-${count.index}"
  location              = "West US" # Can change: Modify location as needed
  resource_group_name   = "testingcncbotnet" # Must change: Replace with your resource group name
  network_interface_ids = [azurerm_network_interface.bots_nic[count.index].id]
  vm_size               = "Standard_B1s" # Can change: Modify Size as needed

  storage_os_disk {
    name              = "bot-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_profile {
    computer_name  = "bot-vm-${count.index}"
    admin_username = "azureuser" # Can change: Modify username as needed
    admin_password = "YourStrongPassword123!" # Can change: password location as needed
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
