module "lxc_media" {
  source       = "./modules/proxmox_lxc"
  hostname     = "media-lxc"
  cores        = 2
  memory       = 2048
  ip_address   = "192.168.0.151/24"
  gateway      = "192.168.0.1"
  unprivileged = true
  nesting      = true
  tags         = ["media"]
  admin_ip     = var.admin_ip
  proxy_ip     = "192.168.0.150"
  service_port = "8096"
  ssh_public_key = var.ssh_public_key
}
