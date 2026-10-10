variable "hostname" { type = string }
variable "cores" { type = number }
variable "memory" { type = number }
variable "ip_address" { type = string }

variable "vmid" {
  type        = number
  description = "ID único del contenedor en Proxmox VE"
  default     = null
}

variable "gateway" { 
  type    = string 
  default = "10.0.20.1" 
}

variable "unprivileged" { 
  type    = bool 
  default = true 
}

variable "nesting" { 
  type    = bool 
  default = true 
}

variable "tags" { 
  type    = list(string) 
  default = [] 
}

variable "proxy_ip" { 
  type        = string 
  default     = null 
  description = "IP del Reverse Proxy autorizado"
}

variable "admin_ip" { 
  type        = string 
  default     = null 
  description = "IP de la PC de administración para SSH"
}

variable "service_port" { 
  type        = string 
  default     = null 
  description = "Puerto del servicio alojado (ej. 8096)"
}

variable "allow_public_web" {
  type        = bool
  default     = false
  description = "Habilita la apertura de los puertos 80 y 443 de entrada para el Reverse Proxy"
}

variable "ssh_public_key" {
  type        = string
  description = "Clave pública SSH para el usuario root"
}