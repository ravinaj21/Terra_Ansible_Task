resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_network_security_group" "rg" {
  name                = var.network_security_name
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "SSH RULE"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [
    azurerm_resource_group.rg
  ]
}


resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_space
  location            = var.location
  resource_group_name = var.rg_name
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_space
  depends_on          = [azurerm_resource_group.rg]
}


resource "azurerm_network_interface" "nic" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = var.rg_name
  depends_on          = [azurerm_resource_group.rg, azurerm_subnet.subnet, azurerm_virtual_network.vnet ]
  ip_configuration {
    name                          = var.ip_name
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}
resource "azurerm_managed_disk" "disk" {
   name     = var.disk_name
   location              = var.location
   resource_group_name   = var.rg_name
   storage_account_type  = "Standard_LRS"
   create_option         = "Empty"
   disk_size_gb          = var.disk_size
   depends_on          = [azurerm_resource_group.rg]
 }
resource "azurerm_public_ip" "pip" {
   name                         = var.pip_name
   location              		= var.location
   resource_group_name   		= var.rg_name
   allocation_method            = "Static"
   depends_on          = [azurerm_resource_group.rg]
 }
output "public_ip" {
    value = data.azurerm_public_ip.public_ip.ip_address
}	
resource "azurerm_network_interface_security_group_association" "rg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.rg.id
  depends_on          = [azurerm_resource_group.rg]
}


resource "azurerm_virtual_machine" "main" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.rg_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = var.vm_size
depends_on          = [azurerm_resource_group.rg]
  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  storage_data_disk {
	 name     = var.disk_name
     managed_disk_id = azurerm_managed_disk.disk.id
     create_option   = "Attach"
     lun             = 1
     disk_size_gb    = var.disk_size
   }
  os_profile {
    computer_name  = "terraform"
    admin_username = var.vm_user
    admin_password = var.vm_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  
}


