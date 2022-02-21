resource "azurerm_resource_group" "RG" {
  name     = "Alina_RG"
  location = "North Europe"
}

data "azurerm_subnet" "vnet" {
  name                 = "epm-rdsp-northeurope-subnet"
  virtual_network_name = "epm-rdsp-northeurope-vnet"
  resource_group_name  = "EPM-RDSP"
}

resource "azurerm_public_ip" "pip" {
    name                         = "pip-testvm-alina"
    location                     = "${azurerm_resource_group.RG.location}"
    resource_group_name          = "${azurerm_resource_group.RG.name}"
    allocation_method            = "Dynamic"
}

resource "azurerm_network_interface" "NIC" {
  name                = "test-vm-nic1"
  location            = "${azurerm_resource_group.RG.location}"
  resource_group_name = "${azurerm_resource_group.RG.name}"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "${data.azurerm_subnet.vnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }
}

resource "azurerm_linux_virtual_machine" "VM1" {
  name                = "test-vm1"
  resource_group_name = "${azurerm_resource_group.RG.name}"
  location            = "${azurerm_resource_group.RG.location}"
  size                = "Standard_D2s_v3"
  admin_username      = "Odmin"
  network_interface_ids = [
    azurerm_network_interface.NIC.id
  ]

  admin_ssh_key {
    username   = "Odmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "procomputers"
    offer     = "centos-8"
    sku       = "centos-8"
    version   = "latest"
  }

  plan {
    name      = "centos-8"
    publisher = "procomputers"
    product   = "centos-8"
  }

  computer_name  = "test-vm1"
  custom_data = filebase64("httpd.sh")

  tags = {
    owner = "Alina_Timakova" 
  }
}

resource "azurerm_cosmosdb_account" "dbacc" {
  name                = "tfex-cosmos-db-alina-test"
  location            = "${azurerm_resource_group.RG.location}"
  resource_group_name = "${azurerm_resource_group.RG.name}"
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = false

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level   = "Session"
  }

  geo_location {
    location          = "${azurerm_resource_group.RG.location}"
    failover_priority = 0
  }

  tags = {
    owner = "Alina_Timakova"
  }
}

resource "azurerm_cosmosdb_mongo_database" "DB" {
  name                = "alina-mongo-db"
  resource_group_name = "${azurerm_resource_group.RG.name}"
  account_name        = "${azurerm_cosmosdb_account.dbacc.name}"
  throughput          = 400
}
