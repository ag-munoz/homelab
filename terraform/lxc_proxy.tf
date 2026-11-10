module "lxc_proxy" {
  source           = "./modules/proxmox_lxc"
  hostname         = "proxy-lxc"
  cores            = 2
  memory           = 2048
  ip_address       = "192.168.0.150/24"
  gateway          = "192.168.0.1"
  unprivileged     = true
  nesting          = true
  tags             = ["proxy"]
  admin_ip         = var.admin_ip
  allow_public_web = true
  ssh_public_key = var.ssh_public_key
  vmid   = 101
  extra_firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      proto   = "tcp"
      dport   = "80,443"
      comment = "Permite acceso web al proxy"
    },
    {
      type    = "out"
      action  = "ACCEPT"
      dest    = "192.168.0.151" 
      comment = "Salida hacia lxc_media"
    },
    {
      type    = "out"
      action  = "ACCEPT"
      dest    = "192.168.0.152"
      comment = "Salida hacia lxc_runner "
    },
    {
      type    = "out"
      action  = "ACCEPT"
      dest    = "192.168.0.153"
      comment = "Salida hacia lxc_appflowy "
    },
    {
      type    = "out"
      action  = "ACCEPT"
      dest    = "192.168.0.154"
      comment = "Salida hacia lxc_ia "
    }
  ]
}
