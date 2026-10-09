variable "proxmox_api_url" {
  type        = string
  description = "URL del API de Proxmox"
}

variable "proxmox_api_token" {
  type        = string
  description = "Token de autenticación de Proxmox"
  sensitive   = true
}

variable "admin_ip" {
  type        = string
  description = "IP de la PC de administración para acceso SSH"
}

variable "ssh_public_key" {
  type        = string
  description = "Clave pública SSH para el usuario root"
}