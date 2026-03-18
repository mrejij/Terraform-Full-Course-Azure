variable "location" {

}
 variable "resource_group_name" {}

variable "service_principal_name" {
  type = string
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "client_id" {}
variable "client_secret" {
  type = string
  sensitive = true
}

variable "keyvault_id" {
  type        = string
  description = "The ID of the Key Vault to store SSH keys"
}

variable "keyvault_name" {
  type        = string
  description = "The name of the Key Vault to store SSH keys"
}

variable "aks_cluster_name" {
  type        = string
  description = "The name of the AKS cluster"
  default = "aks-demo-cluster"
}