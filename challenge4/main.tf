provider "azurerm" {
  version = "= 1.4"
}
terraform {
  required_version = "= 0.11.14"
}

variable "name" {
  default = "haakr-04"
}
variable "location" {
  default = "norwayeast"
}

variable "loginuser" {
  default = "*"
}

variable "loginpassword"{
  default = "*"
}
variable "vmcount" {
  default = 2
}

resource "azurerm_resource_group" "main" {
  name = "${var.name}-rg"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "main" {
  name = "${var.name}-vnet"
  address_space = ["10.0.0.0/16"]
  location = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}
resource "azurerm_subnet" "main" {
  name = "${var.name}-subnet"
  resource_group_name = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix = "10.0.1.0/24"
}

resource "azurerm_network_interface" "main" {
  count = "${var.vmcount}"
  name = "${var.name}-nic${count.index}"
  location = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  ip_configuration {
  name = "config1"
  subnet_id = "${azurerm_subnet.main.id}"
  private_ip_address_allocation = "dynamic"
  public_ip_address_id = "${element(azurerm_public_ip.main.*.id, count.index)}"
 }
}
resource "azurerm_virtual_machine" "main" {
  count = "${var.vmcount}"
  name = "${var.name}-vm${count.index}"
  location = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${element(azurerm_network_interface.main.*.id, count.index)}"]
  vm_size = "Standard_A2_v2"
  storage_image_reference {
  publisher = "MicrosoftWindowsServer"
  offer = "WindowsServer"
  sku = "2016-Datacenter"
  version = "latest"
 }
  storage_os_disk {
  name = "${var.name}vm${count.index}-osdisk"
  caching = "ReadWrite"
  create_option = "FromImage"
  managed_disk_type = "Standard_LRS"
 }
  os_profile {
  computer_name = "${var.name}vm${count.index}"
  admin_username = "${var.loginuser}"
  admin_password = "${var.loginpassword}"
 }
  os_profile_windows_config {}
#  storage_data_disk{
#    name = "${var.name}vm-xtradisk"
#    caching = "ReadWrite"
#    managed_disk_type = "Standard_LRS"
#   disk_size_gb = 10
#    lun = "11"
#    create_option = "Empty"
#  }
}

resource "azurerm_public_ip" "main" {
  count = "${var.vmcount}"
  name = "${var.name}-pubip${count.index}"
  location = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  public_ip_address_allocation = "static"
  domain_name_label = "haakonerkul${count.index}"
}

output "private-ip" {
  value = "${azurerm_network_interface.main.*.private_ip_address}"
  description = "Private IP Address"
}
output "public-ip" {
  value = "${azurerm_public_ip.main.*.ip_address}"
  description = "Public IP Address"
}
