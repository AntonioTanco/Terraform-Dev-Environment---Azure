terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.85.0"
    }
  }
}

provider "azurerm" {
  features {

  }
}

#Creating a new resource
resource "azurerm_resource_group" "ultra-rg" {
  name     = "ultra-resources"
  location = "eastus2"
  tags = {
    environment = "Dev"
  }
}

#Creating a new virtual network
resource "azurerm_virtual_network" "ultra-vn" {
  name = "ultra-network"
  resource_group_name = azurerm_resource_group.ultra-rg.name
  location = azurerm_resource_group.ultra-rg.location
  address_space = ["10.123.0.0/16"]

  tags = {
    environment = "Dev"
  }
}

#Creating a subnet
resource "azurerm_subnet" "ultra-subnet" {
    name = "ultra-subnet-1"
    resource_group_name = azurerm_resource_group.ultra-rg.name
    virtual_network_name = azurerm_virtual_network.ultra-vn.name
    address_prefixes = ["10.123.1.0/24"]
}

#Creating a network security group
resource "azurerm_network_security_group" "ultra-sg" {
  name = "ultra-sg"
  location = azurerm_resource_group.ultra-rg.location
  resource_group_name = azurerm_resource_group.ultra-rg.name

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_security_rule" "ultra-dev-rule" {
  name = "ultra-dev-rule"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "*"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefix = "71.247.252.159/32"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.ultra-rg.name
  network_security_group_name = azurerm_network_security_group.ultra-sg.name
}

resource "azurerm_subnet_network_security_group_association" "ultra-sga" {
  subnet_id = azurerm_subnet.ultra-subnet.id
  network_security_group_id = azurerm_network_security_group.ultra-sg.id
}

resource "azurerm_public_ip" "ultra-ip" {
  name = "ultra-ip-1"
  resource_group_name = azurerm_resource_group.ultra-rg.name
  location = azurerm_resource_group.ultra-rg.location
  allocation_method = "Dynamic"

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_interface" "ultra-nic" {
  name = "ultra-nic"
  location = azurerm_resource_group.ultra-rg.location
  resource_group_name = azurerm_resource_group.ultra-rg.name

  ip_configuration {
    name = "Internal"
    subnet_id = azurerm_subnet.ultra-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ultra-ip.id
  }

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_linux_virtual_machine" "ultra-vm" {
  name = "ultra-vm"
  resource_group_name = azurerm_resource_group.ultra-rg.name
  location = azurerm_resource_group.ultra-rg.location
  size = "Standard_F2"
  admin_username = "dev_admin"
  network_interface_ids = [azurerm_network_interface.ultra-nic.id]

  custom_data = base64encode(file("docker.sh"))

  admin_ssh_key {
    username = "dev_admin"
    public_key = file("~/.ssh/ultraazurekey.pub")
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("windows-ssh-script.tpl", 
    {
      hostname = self.public_ip_address,
      user = "dev_admin",
      IdentityFile = "~/.ssh/ultraazurekey"
    })

    interpreter = ["Powershell", "-command" ]
  }

  tags = {
    environment = "Dev"
  }
}

