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
}