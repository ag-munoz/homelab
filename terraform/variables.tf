variable "proxmox_api_url" {
  type        = string
  description = "URL del API de Proxmox"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "ID del token de API de Proxmox"
}

variable "proxmox_api_token" {
  type        = string
  description = "Token de autenticación de Proxmox"
  sensitive   = true
}

variable "admin_ip" {
  type        = string
  description = "IP de la PC de administración para acceso SSH"
  default     = "192.168.0.106/24"
}

variable "ssh_public_key" {
  type        = string
  description = "Clave pública SSH para el usuario root"
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPtKycX4q6a1zZWvJVWhK+DBvMhkcetIP/uLrkC+OnFU homelab"
}