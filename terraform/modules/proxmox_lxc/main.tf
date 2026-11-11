terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.70.0"
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

  dynamic "rule" {
    for_each = var.extra_firewall_rules
    content {
      type    = rule.value.type
      action  = rule.value.action
      source  = rule.value.source
      dest    = rule.value.dest
      proto   = rule.value.proto
      dport   = rule.value.dport
      comment = rule.value.comment
    }
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    source  = "192.168.0.152"
    proto   = "tcp"
    dport   = "22"
    comment = "Permite ejecucion de playbooks desde el Ansible Runner"
  }

  rule {
    type    = "in"
    action  = "DROP"
    dest    = "0.0.0.0/0"
    comment = "Bloquea todo el trafico entrante"
  }


}
