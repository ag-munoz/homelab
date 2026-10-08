module "lxc_media" {
  source       = "./modules/proxmox_lxc"
  hostname     = "media-lxc"
  cores        = 2
  memory       = 2048
  ip_address   = "10.0.20.2/24"
  gateway      = "10.0.20.1"
  vlan_tag     = 20
  unprivileged = true
  nesting      = true
  tags         = ["media"]
  admin_ip     = var.admin_ip
  proxy_ip     = "10.0.10.2"
  service_port = "8096"
}
