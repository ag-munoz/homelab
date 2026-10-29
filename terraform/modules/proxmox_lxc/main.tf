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
  vm_id        = var.vmid

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
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
    user_account {
      keys = [
        var.ssh_public_key
      ]
    }
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  network_interface {
    name     = "eth0"
    bridge   = "vmbr0"
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

  mount_point {
    volume = "/mnt/pve/disk1"
    path   = "/mnt/pve/disk1"
  }

  device_passthrough {
    path = "/dev/dri/renderD128"
    mode = "0666"
  }

  device_passthrough {
    path = "/dev/dri/card0"
    mode = "0666"
  }
}

resource "proxmox_virtual_environment_firewall_options" "lxc_firewall_options" {
  node_name    = "pve"
  container_id = proxmox_virtual_environment_container.lxc.id
  enabled      = true
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

  rule {
    type    = "out"
    action  = "REJECT"
    dest    = "192.168.0.0/24"
    comment = "Bloquea salida a la LAN domestica"
  }


}
