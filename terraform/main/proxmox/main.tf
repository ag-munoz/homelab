terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.60.0"
    }
  }
}

resource "proxmox_virtual_environment_container" "lxc" {
  node_name    = "pve"
  unprivileged = var.unprivileged
  tags         = var.tags

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    type             = "debian"
  }

  initialization {
    hostname = var.hostname
    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }
  }

  network_interface {
    name     = "eth0"
    bridge   = "vmbr0"
    vlan_id  = var.vlan_tag
    firewall = true # Requerido para aplicar las reglas de Proxmox
  }

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
  }

  features {
    nesting = var.nesting
  }
}

resource "proxmox_virtual_environment_firewall_rules" "lxc_firewall" {
  node_name    = "pve"
  container_id = proxmox_virtual_environment_container.lxc.id

  rule {
    type    = "in"
    action  = "ACCEPT"
    source  = var.proxy_ip
    proto   = "tcp"
    dport   = var.service_port
    comment = "Permite acceso unicamente desde el Reverse Proxy"
    enabled = var.proxy_ip != null && var.service_port != null
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "80,443"
    comment = "Permite trafico HTTP/HTTPS de entrada al Proxy"
    enabled = var.allow_public_web
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    source  = var.admin_ip
    proto   = "tcp"
    dport   = "22"
    comment = "Permite SSH desde la PC de administracion para Ansible"
    enabled = var.admin_ip != null
  }

  rule {
    type    = "out"
    action  = "REJECT"
    dest    = "192.168.0.0/24"
    comment = "Bloquea salida a la LAN domestica"
  }

  rule {
    type    = "out"
    action  = "ACCEPT"
    proto   = "udp"
    dport   = "53"
    comment = "Permite resolucion DNS externa"
  }

  rule {
    type    = "out"
    action  = "ACCEPT"
    proto   = "tcp"
    dport   = "80,443"
    comment = "Permite trafico HTTP/HTTPS saliente a Internet"
  }
}