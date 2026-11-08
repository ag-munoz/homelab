module "lxc_ia" {
  source       = "./modules/proxmox_lxc"
  hostname     = "ia-lxc"
  cores        = 2
  memory       = 2048
  ip_address   = "192.168.0.154/24"
  gateway      = "192.168.0.1"
  unprivileged = false
  nesting      = true
  tags         = ["ia"]
  admin_ip     = var.admin_ip
  proxy_ip     = "192.168.0.150"
  service_port = "80"
  ssh_public_key = var.ssh_public_key
  vmid   = 104
}
