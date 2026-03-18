variable "keyvault_name" {
    type = string
}

variable "location" {
    type = string
}
variable "resource_group_name" {
    type = string
}

variable "service_principal_name" {
    type = string
}

variable "sku_name" {
  type = string
  description = "sku for key-vault service"
  default = "standard"
}

variable "service_principal_object_id" {}
variable "service_principal_tenant_id" {}