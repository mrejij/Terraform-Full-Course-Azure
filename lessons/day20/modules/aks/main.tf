# Datasource to get Latest Azure AKS latest Version
# Check if there is a var with the version name , if not , use the 
# latest version, if there is a var, use that version
# make sure the version specified in var is valid

data "azurerm_kubernetes_service_versions" "current" {
  location = var.location
  include_preview = false  
}

# Generate SSH private key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"   # Options: RSA, ECDSA, ED25519
  rsa_bits  = 4096    # Key size for RSA
}

# Upload private key to Key Vault
resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "aks-ssh-private-key"
  value        = tls_private_key.ssh_key.private_key_pem
  key_vault_id = var.keyvault_id
}

# Upload public key to Key Vault
resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "aks-ssh-public-key"
  value        = tls_private_key.ssh_key.public_key_openssh
  key_vault_id = var.keyvault_id
}
 

resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                  = var.aks_cluster_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  dns_prefix            = "${var.resource_group_name}-cluster"           
  kubernetes_version    =  data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${var.resource_group_name}-nrg"
  
  default_node_pool {
    name       = "defaultpool"
    vm_size    = "Standard_DS2_v2"
    zones   = [1, 2, 3]
    auto_scaling_enabled = true
    max_count            = 3
    min_count            = 1
    os_disk_size_gb      = 30
    type                 = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type"    = "system"
      "environment"      = "prod"
      "nodepoolos"       = "linux"
     } 
   tags = {
      "nodepool-type"    = "system"
      "environment"      = "prod"
      "nodepools"       = "linux"
   } 
  }

  service_principal  {
    client_id = var.client_id
    client_secret = var.client_secret
  }

# to do: generate the ssh keys using tls_private_key
# upload the key to key vault

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = tls_private_key.ssh_key.public_key_openssh
    }
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
  }
  
  depends_on = [ azurerm_key_vault_secret.ssh_public_key ]
    
  }


