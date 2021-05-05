# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
  name     = "myResourceGroup3"
  location = "francecentral"
  tags = {
    environment = "Terraform Demo"
  }
}

data "azurerm_resource_group" "myterraformgroup" {
  name       = "myResourceGroup3"
  depends_on = [azurerm_resource_group.myterraformgroup]
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "myVnet"
  address_space       = ["10.3.0.0/16"]
  location            = data.azurerm_resource_group.myterraformgroup.location
  resource_group_name = data.azurerm_resource_group.myterraformgroup.name
  dns_servers         = ["8.8.8.8"]

  tags = {
    environment = "Terraform Demo"
  }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet1" {
  name                 = "mySubnet1"
  resource_group_name  = data.azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes     = ["10.3.1.0/24"]
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNetworkSecurityGroup"
  location            = data.azurerm_resource_group.myterraformgroup.location
  resource_group_name = data.azurerm_resource_group.myterraformgroup.name

  tags = {
    environment = "Terraform Demo"
  }
}

resource "azurerm_network_security_rule" "https" {
  name                        = "HTTPS"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.myterraformgroup.name
  network_security_group_name = azurerm_network_security_group.myterraformnsg.name
}
resource "azurerm_network_security_rule" "winrm" {
  name                        = "winrm"
  priority                    = 1010
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5985"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.myterraformgroup.name
  network_security_group_name = azurerm_network_security_group.myterraformnsg.name
}
resource "azurerm_network_security_rule" "winrm-out" {
  name                        = "winrm-out"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "5985"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.myterraformgroup.name
  network_security_group_name = azurerm_network_security_group.myterraformnsg.name
}
resource "azurerm_network_security_rule" "rdp" {
  name                        = "RDP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.myterraformgroup.name
  network_security_group_name = azurerm_network_security_group.myterraformnsg.name
}


# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                    = "myPublicIP"
  location                = data.azurerm_resource_group.myterraformgroup.location
  resource_group_name     = data.azurerm_resource_group.myterraformgroup.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
  domain_name_label       = "keolisdemo"

  tags = {
    environment = "Terraform Demo"
  }
}

data "azurerm_public_ip" "myterraformpublicip" {
  name                = azurerm_public_ip.myterraformpublicip.name
  resource_group_name = azurerm_virtual_machine.myterraformvm.resource_group_name
  depends_on = [
    azurerm_public_ip.myterraformpublicip
  ]
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  name                = "myNIC"
  location            = data.azurerm_resource_group.myterraformgroup.location
  resource_group_name = data.azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }

  tags = {
    environment = "Terraform Demo"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "singlevm" {
  network_interface_id      = azurerm_network_interface.myterraformnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

resource "azurerm_storage_account" "myterraformsa" {
  name                     = "mydiagsa"
  resource_group_name      = data.azurerm_resource_group.myterraformgroup.name
  location                 = data.azurerm_resource_group.myterraformgroup.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
  min_tls_version          = "TLS1_2"
}

resource "random_password" "password" {
  length           = 12
  special          = true
  override_special = "_%@"
}

resource "azurerm_virtual_machine" "myterraformvm" {
  name                             = "myVM"
  location                         = data.azurerm_resource_group.myterraformgroup.location
  resource_group_name              = data.azurerm_resource_group.myterraformgroup.name
  network_interface_ids            = [azurerm_network_interface.myterraformnic.id]
  vm_size                          = "Standard_DS1_v2"
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.myterraformsa.primary_blob_endpoint
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "myvm"
    admin_username = "azureuser"
    admin_password = random_password.password.result
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
    winrm {
      protocol        = "http"
      certificate_url = ""
    }
  }

}
